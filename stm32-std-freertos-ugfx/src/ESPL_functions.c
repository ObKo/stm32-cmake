/**
 * This file implements the initialization of the ESPLaboratory project hardware and software.
 * Further, it takes care of some low level functions like switching the display buffers.
 * It also implements IRQ handlers for the display and the UART.
 *
 * @author: Jonathan Müller-Boruttau, Nadja Peters nadja.peters@tum.de (RCS, TUM)
 *
 */
#include "includes.h"

// Set in Header:
// QueueHandle_t ESPL_RxQueue;
// SemaphoreHandle_t ESPL_DisplayReady

// Needs to be volatile, otherwise values get discarded by compiler
// back or front layer of the display
uint16_t current_layer;

/**
 * Function which initializes the GPIOs.
 */
void gpioInit() {
	GPIO_InitTypeDef GPIO_InitStruct;
	ADC_InitTypeDef ADC_InitStruct;

	// Enable clock for GPIOA, USART1 and ADC
	// if it is not enabled, peripherals will not work
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA, ENABLE);
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOE, ENABLE);
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOF, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_ADC1, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_ADC2, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_ADC3, ENABLE);

	// Initialize UART Pins
	// Tell pins PA9 and PA10 which alternating function you will use
	// Important: Make sure, these lines are before pins configuration!
	//
	// Initialize pins as alternating function
	GPIO_InitStruct.GPIO_Pin = GPIO_Pin_9 | GPIO_Pin_10;
	GPIO_InitStruct.GPIO_Mode = GPIO_Mode_AF;
	GPIO_InitStruct.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStruct.GPIO_PuPd = GPIO_PuPd_UP;
	GPIO_InitStruct.GPIO_Speed = GPIO_Speed_100MHz;
	GPIO_Init(GPIOA, &GPIO_InitStruct);

	GPIO_PinAFConfig(GPIOA, GPIO_PinSource9, GPIO_AF_USART1);
	GPIO_PinAFConfig(GPIOA, GPIO_PinSource10, GPIO_AF_USART1);


	// Initialize Onboard Button
	GPIO_InitStruct.GPIO_Pin = GPIO_Pin_0;
	GPIO_InitStruct.GPIO_Mode = GPIO_Mode_IN;
	GPIO_InitStruct.GPIO_Speed = GPIO_Speed_100MHz;
	GPIO_InitStruct.GPIO_PuPd = GPIO_PuPd_NOPULL;
	GPIO_Init(GPIOA, &GPIO_InitStruct);


	//Initialize External Buttons
	GPIO_InitStruct.GPIO_Pin = ESPL_Pins_GPIOE;
	GPIO_InitStruct.GPIO_Mode = GPIO_Mode_IN;
	GPIO_InitStruct.GPIO_Speed = GPIO_Speed_100MHz;
	GPIO_InitStruct.GPIO_PuPd = GPIO_PuPd_UP;
	GPIO_Init(GPIOE, &GPIO_InitStruct);

	GPIO_InitStruct.GPIO_Pin = ESPL_Pins_GPIOA;
	GPIO_Init(GPIOA, &GPIO_InitStruct);


	// Initialize ADC for both axes
	GPIO_InitStruct.GPIO_Pin = ESPL_Pin_Joystick_1;
	GPIO_InitStruct.GPIO_Mode = GPIO_Mode_AN;
	GPIO_InitStruct.GPIO_Speed = GPIO_Speed_100MHz;
	GPIO_InitStruct.GPIO_PuPd = GPIO_PuPd_NOPULL;
	GPIO_Init(ESPL_Register_Joystick_1, &GPIO_InitStruct);

	GPIO_InitStruct.GPIO_Pin = ESPL_Pin_Joystick_2;
	GPIO_Init(ESPL_Register_Joystick_2, &GPIO_InitStruct);

	GPIO_InitStruct.GPIO_Pin = ESPL_Pin_VBat;
	GPIO_Init(ESPL_Register_VBat, &GPIO_InitStruct);

	ADC_CommonInitTypeDef ADC_CommonInitStruct;
	ADC_CommonInitStruct.ADC_Mode = ADC_Mode_Independent;
	ADC_CommonInitStruct.ADC_Prescaler = ADC_Prescaler_Div2;
	ADC_CommonInitStruct.ADC_DMAAccessMode = ADC_DMAAccessMode_Disabled;
	ADC_CommonInitStruct.ADC_TwoSamplingDelay = ADC_TwoSamplingDelay_5Cycles;
	ADC_CommonInit(&ADC_CommonInitStruct);

	ADC_DeInit();

	ADC_InitStruct.ADC_Resolution = ADC_Resolution_12b;
	ADC_InitStruct.ADC_ScanConvMode = DISABLE;
	ADC_InitStruct.ADC_ContinuousConvMode = ENABLE;
	ADC_InitStruct.ADC_ExternalTrigConv = ADC_ExternalTrigConvEdge_None;
	ADC_InitStruct.ADC_DataAlign = ADC_DataAlign_Right;
	ADC_InitStruct.ADC_NbrOfConversion = 1;

	ADC_Init(ESPL_ADC_Joystick_1, &ADC_InitStruct);
	ADC_Init(ESPL_ADC_Joystick_2, &ADC_InitStruct);
	ADC_Init(ESPL_ADC_VBat, &ADC_InitStruct);

	ADC_RegularChannelConfig(ESPL_ADC_Joystick_1, ESPL_Channel_Joystick_1, 1, ADC_SampleTime_480Cycles);
	ADC_RegularChannelConfig(ESPL_ADC_Joystick_2, ESPL_Channel_Joystick_2, 1, ADC_SampleTime_480Cycles);
	ADC_RegularChannelConfig(ESPL_ADC_VBat, ESPL_Channel_VBat, 1, ADC_SampleTime_480Cycles);

	ADC_ContinuousModeCmd(ESPL_ADC_Joystick_1, ENABLE);
	ADC_ContinuousModeCmd(ESPL_ADC_Joystick_2, ENABLE);
	ADC_ContinuousModeCmd(ESPL_ADC_VBat, ENABLE);

	ADC_DMACmd(ESPL_ADC_Joystick_1, DISABLE);
	ADC_DMACmd(ESPL_ADC_Joystick_2, DISABLE);
	ADC_DMACmd(ESPL_ADC_VBat, DISABLE);

	ADC_Cmd(ESPL_ADC_Joystick_1, ENABLE);
	ADC_Cmd(ESPL_ADC_Joystick_2, ENABLE);
	ADC_Cmd(ESPL_ADC_VBat, ENABLE);

	ADC_SoftwareStartConv(ESPL_ADC_Joystick_1);
	ADC_SoftwareStartConv(ESPL_ADC_Joystick_2);
	ADC_SoftwareStartConv(ESPL_ADC_VBat);

	// Initialize USART1
	// Activate USART1
	// Initialize Receive Interrupt

	USART_InitTypeDef USART_InitStruct;
	NVIC_InitTypeDef NVIC_InitStruct;

	USART_InitStruct.USART_BaudRate = 19200;
	USART_InitStruct.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
	USART_InitStruct.USART_Mode = USART_Mode_Tx | USART_Mode_Rx;
	USART_InitStruct.USART_Parity = USART_Parity_No;
	USART_InitStruct.USART_StopBits = USART_StopBits_1;
	USART_InitStruct.USART_WordLength = USART_WordLength_8b;
	USART_Init(USART1, &USART_InitStruct);
	// enable the USART1 receive interrupt
	USART_ITConfig(USART1, USART_IT_RXNE, ENABLE);

	NVIC_InitStruct.NVIC_IRQChannel = USART1_IRQn;
	NVIC_InitStruct.NVIC_IRQChannelCmd = ENABLE;
	NVIC_InitStruct.NVIC_IRQChannelPreemptionPriority = 5;
	NVIC_InitStruct.NVIC_IRQChannelSubPriority = 5;
	NVIC_Init(&NVIC_InitStruct);

	USART_Cmd(USART1, ENABLE);

	// Initialize the line interrupt which occurs
	// when the MCU has finished writing to the display and the framebuffer can be modified

	NVIC_InitStruct.NVIC_IRQChannel = LTDC_IRQn;
	NVIC_InitStruct.NVIC_IRQChannelCmd = ENABLE;
	NVIC_InitStruct.NVIC_IRQChannelPreemptionPriority = 5;
	NVIC_InitStruct.NVIC_IRQChannelSubPriority = 5;
	NVIC_Init(&NVIC_InitStruct);

	LTDC_ITConfig(LTDC_FLAG_LI, ENABLE);
	LTDC_ITConfig(LTDC_FLAG_RR, DISABLE);
	LTDC_LIPConfig(324);

	current_layer = LCD_BACKGROUND_LAYER;
}

void USART1_IRQHandler(void) {
	char i = 0;
	if (USART_GetITStatus(USART1, USART_IT_RXNE)) {
		i = USART1->DR;
		xQueueSendToBackFromISR(ESPL_RxQueue, &i, NULL);
	}
}

void LTDC_IRQHandler(void) {
	if (LTDC_GetITStatus(LTDC_IT_LI)) {
		xSemaphoreGiveFromISR(ESPL_DisplayReady, NULL);
		taskYIELD();
		LTDC_ClearITPendingBit(LTDC_IT_LI);
	}
}

void UART_SendData(uint8_t data) {
	USART_SendData(USART1, (uint8_t) data);
	while (USART_GetFlagStatus(USART1, USART_FLAG_TC) == RESET) {// Stores lines to be drawn
	}
}

void ESPL_SystemInit(void) {
	/* Setup STM32 system (clock, PLL and Flash configuration) */
	SystemInit();

	/* Ensure all priority bits are assigned as preemption priority bits. */
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_4);

	/*Initialize LCD and library*/

//	gdispSetOrientation(GDISP_ROTATE_270);
//	gdispSetOrientation(GDISP_ROTATE_LANDSCAPE);
	gfxInit();
	LTDC_DitherCmd(DISABLE);

	LTDC_LayerAlpha(LTDC_Layer1, 0xFF);
	LTDC_LayerAlpha(LTDC_Layer2, 0xFF);

	LTDC_ReloadConfig(LTDC_IMReload);
//	gdispSetOrientation(GDISP_ROTATE_270);
//	gdispSetOrientation(GDISP_ROTATE_LANDSCAPE);

	/*Initialize UART Receive Queue*/
	ESPL_RxQueue = xQueueCreate(100, sizeof(char));

	/*Initialize Display Line Interrupt Semaphore*/
	ESPL_DisplayReady = xSemaphoreCreateBinary();

	/*Initialize GPIO Pins, UART and UART_Rx interrupt*/
	gpioInit();
}

void ESPL_DrawLayer() {

	if (current_layer == LCD_BACKGROUND_LAYER) { //Background equals layer 1
		LCD_SetLayer(LCD_FOREGROUND_LAYER);
		LTDC_LayerAlpha(LTDC_Layer2, (uint8_t) 0x00);
		LTDC_ReloadConfig(LTDC_IMReload);
		current_layer = LCD_FOREGROUND_LAYER;
	} else {
		LCD_SetLayer(LCD_BACKGROUND_LAYER);
		LTDC_LayerAlpha(LTDC_Layer2, (uint8_t) 0xff);
		LTDC_ReloadConfig(LTDC_IMReload);
		current_layer = LCD_BACKGROUND_LAYER;
	}
}

void vApplicationStackOverflowHook(TaskHandle_t pxTask, char *pcTaskName) {
	(void) pxTask;
	(void) pcTaskName;

	for (;;)
		;
}

void vApplicationTickHook(void) {
}
