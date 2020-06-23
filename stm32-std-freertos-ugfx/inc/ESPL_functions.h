/**
 * This file defines the hardware pin assignment for the microprocessor.
 * You can see which gpio pins are connected to which hardware components.
 *
 * @author: Jonathan Müller-Boruttau, Nadja Peters nadja.peters@tum.de (RCS, TUM)
 */
#ifndef ESPL_functions_INCLUDED
#define ESPL_functions_INCLUDED

#include "FreeRTOS.h"
#include "semphr.h"
#include "stm32f4xx.h"

// Buttons
#define ESPL_Register_Button_A GPIOE
#define ESPL_Register_Button_B GPIOE
#define ESPL_Register_Button_C GPIOE
#define ESPL_Register_Button_D GPIOE
#define ESPL_Register_Button_E GPIOA
#define ESPL_Register_Button_K GPIOE

#define ESPL_Pin_Button_A GPIO_Pin_6
#define ESPL_Pin_Button_B GPIO_Pin_4
#define ESPL_Pin_Button_C GPIO_Pin_5
#define ESPL_Pin_Button_D GPIO_Pin_2
#define ESPL_Pin_Button_E GPIO_Pin_0
#define ESPL_Pin_Button_K GPIO_Pin_3

#define ESPL_Pins_GPIOE                                                        \
	GPIO_Pin_6 | GPIO_Pin_4 | GPIO_Pin_5 | GPIO_Pin_2 | GPIO_Pin_3
#define ESPL_Pins_GPIOA GPIO_Pin_0

// Joysticks
#define ESPL_Register_Joystick_1 GPIOF
#define ESPL_Pin_Joystick_1 GPIO_Pin_6
#define ESPL_ADC_Joystick_1 ADC3
#define ESPL_Channel_Joystick_1 ADC_Channel_4

#define ESPL_Register_Joystick_2 GPIOA
#define ESPL_Pin_Joystick_2 GPIO_Pin_5
#define ESPL_ADC_Joystick_2 ADC1
#define ESPL_Channel_Joystick_2 ADC_Channel_5

#define ESPL_Register_VBat GPIOC
#define ESPL_Pin_VBat GPIO_Pin_3
#define ESPL_ADC_VBat ADC2
#define ESPL_Channel_VBat ADC_Channel_13

extern QueueHandle_t ESPL_RxQueue;
extern SemaphoreHandle_t ESPL_DisplayReady;

extern uint16_t current_layer;

void USART1_IRQHandler(void);
void LTDC_IRQHandler(void);

void UART_SendData(uint8_t data);
void ESPL_SystemInit(void);
void ESPL_DrawLayer(void);
#endif
