/**
 * This is the main file of the ESPLaboratory Demo project.
 * It implements simple sample functions for the usage of UART,
 * writing to the display and processing user inputs.
 *
 * @author: Alex Hoffman alex.hoffman@tum.de (RCS, TUM)
 * 			Jonathan M��ller-Boruttau,
 * 			Tobias Fuchs tobias.fuchs@tum.de
 * 			Nadja Peters nadja.peters@tum.de (RCS, TUM)
 *
 */
#include "includes.h"

#define DISPLAY_SIZE_X  320
#define DISPLAY_SIZE_Y  240

#define PAUSED_TEXT_X(TEXT)     DISPLAY_SIZE_X / 2 - (gdispGetStringWidth(TEXT, font1) / 2)
#define PAUSED_TEXT_Y(LINE)     DISPLAY_SIZE_Y / 2 - (gdispGetFontMetric(font1, fontHeight) * -(LINE + 0.5))

#define BUTTON_QUEUE_LENGTH 20
#define STATE_QUEUE_LENGTH 1

#define STATE_COUNT 2

#define STATE_ONE   1
#define STATE_TWO   2

#define NEXT_TASK   1
#define PREV_TASK   2

// Read only, there should be no globals being written to that are not locked via semaphores etc
// Start and stop bytes for the UART protocol
static const uint8_t startByte = 0xAA, stopByte = 0x55;
font_t font1; // Load font for ugfx

//Function prototypes
void frameSwapTask(void * params);
void basicStateMachine(void * params);
void checkButtons(void * params);

void drawTask1(void * params);
void drawTask2(void * params);

QueueHandle_t ESPL_RxQueue; // Already defined in ESPL_Functions.h
SemaphoreHandle_t ESPL_DisplayReady;
SemaphoreHandle_t DrawReady; // After swapping buffer calll drawing

/*
 * All variables handled by multiple tasks should be sent in SAFE ways, ie. using queues.
 * Global variables should only be used for managing handles to the RTOS components used
 * to perform thread safe, multi-threaded programming.
 */
// Stores lines to be drawn
QueueHandle_t ButtonQueue;
QueueHandle_t StateQueue;

// Task handles, used for task control
TaskHandle_t frameSwapHandle;
TaskHandle_t drawTask1Handle;
TaskHandle_t drawTask2Handle;
TaskHandle_t stateMachineHandle;

int main(void) {
	// Initialize Board functions and graphics
	ESPL_SystemInit();

	font1 = gdispOpenFont("DejaVuSans24*");

	// Initializes Draw Queue with 100 lines buffer
	ButtonQueue = xQueueCreate(BUTTON_QUEUE_LENGTH, sizeof(struct buttons));
	StateQueue = xQueueCreate(STATE_QUEUE_LENGTH, sizeof(unsigned char));

	ESPL_DisplayReady = xSemaphoreCreateBinary();
	DrawReady = xSemaphoreCreateBinary();

	// Initializes Tasks with their respective priority
	// Core tasks
	xTaskCreate(frameSwapTask, "frameSwapper", 1000, NULL, 4, &frameSwapHandle);
	xTaskCreate(basicStateMachine, "StateMachine", 1000, NULL, 3,
			stateMachineHandle);
	xTaskCreate(checkButtons, "checkButtons", 1000, NULL, 3, NULL);

	// Drawing tasks for various things
	xTaskCreate(drawTask1, "drawTask1", 1000, NULL, 2, &drawTask1Handle);
	xTaskCreate(drawTask2, "drawTask2", 1000, NULL, 2, &drawTask2Handle);

	vTaskSuspend(drawTask1Handle);
	vTaskSuspend(drawTask2Handle);

	// Start FreeRTOS Scheduler
	vTaskStartScheduler();
}

/*
 * Frame swapping happens in the background, seperate to all other system tasks.
 * This way it can be guarenteed that the 50fps requirement of the system
 * can be met.
 */
void frameSwapTask(void * params) {
	TickType_t xLastWakeTime;
	xLastWakeTime = xTaskGetTickCount();
	const TickType_t frameratePeriod = 20;

	while (1) {

		// Draw next frame
		xSemaphoreGive(DrawReady);
		// Wait for display to stop writing
		xSemaphoreTake(ESPL_DisplayReady, portMAX_DELAY);
		// Swap buffers
		ESPL_DrawLayer();

		vTaskDelayUntil(&xLastWakeTime, frameratePeriod);
	}
}

/*
 * Changes the state, either forwards of backwards
 */
void changeState(volatile unsigned char *state, unsigned char forwards) {

	switch (forwards) {
	case 0:
		if (*state == 0)
			*state = STATE_COUNT;
		else
			(*state)--;
		break;
	case 1:
		if (*state == STATE_COUNT)
			*state = 0;
		else
			(*state)++;
		break;
	default:
		break;
	}
}

/*
 * Example basic state machine with sequential states
 */
void basicStateMachine(void * params) {
	unsigned char current_state = 1; // Default state
	unsigned char state_changed = 1; // Only re-evaluate state if it has changed
	unsigned char input = 0;

	while (1) {

		if (state_changed)
			goto initial_state;

		// Handle state machine input
		if (xQueueReceive(StateQueue, &input, portMAX_DELAY) == pdTRUE) {
			if (input == NEXT_TASK) {
				changeState(&current_state, 1);
				state_changed = 1;
			} else if (input == PREV_TASK) {
				changeState(&current_state, 0);
				state_changed = 1;
			}
		}

		initial_state:
		// Handle current state
		if (state_changed) {
			switch (current_state) {
			case STATE_ONE:
				vTaskSuspend(drawTask2Handle);
				vTaskResume(drawTask1Handle);
				state_changed = 0;
				break;
			case STATE_TWO:
				vTaskSuspend(drawTask1Handle);
				vTaskResume(drawTask2Handle);
				state_changed = 0;
				break;
			default:
				break;
			}
		}
	}
}

/**
 * Example task which draws to the display.
 */
void drawTask1(void * params) {
	char str[100]; // buffer for messages to draw to display
	struct buttons buttonStatus; // joystick queue input buffer
	const unsigned char next_state_signal = NEXT_TASK;

	/* building the cave:
	 caveX and caveY define the top left corner of the cave
	 circle movment is limited by 64px from center in every direction
	 (coordinates are stored as uint8_t unsigned bytes)
	 so, cave size is 128px */
	const uint16_t caveX = DISPLAY_SIZE_X / 2 - UINT8_MAX / 4, caveY =
	DISPLAY_SIZE_Y / 2 - UINT8_MAX / 4, caveSize = UINT8_MAX / 2;
	uint16_t circlePositionX = caveX, circlePositionY = caveY;

	// Start endless loop
	while (1) {

		if (xSemaphoreTake(DrawReady, portMAX_DELAY) == pdTRUE) { // Block until screen is ready

			while (xQueueReceive(ButtonQueue, &buttonStatus, 0) == pdTRUE)
				;

			// State machine input
			if (buttonStatus.E)
				xQueueSend(StateQueue, &next_state_signal, 100);
		    
            // Clear background
		    gdispClear(White);

			// Draw rectangle "cave" for circle
			// By default, the circle should be in the center of the display.
			// Also, the circle can only move by 127px in both directions (position is limited to uint8_t)
			gdispFillArea(caveX - 10, caveY - 10, caveSize + 20, caveSize + 20,
					Red);
			// color inner white
			gdispFillArea(caveX, caveY, caveSize, caveSize, White);

			// Generate string with current joystick values
			sprintf(str, "Axis 1: %5d|Axis 2: %5d|VBat: %5d",
					buttonStatus.joystick.x, buttonStatus.joystick.y,
					ADC_GetConversionValue(ESPL_ADC_VBat));
			// Print string of joystick values
			gdispDrawString(0, 0, str, font1, Black);

			// Generate string with current joystick values
			sprintf(str, "A: %d|B: %d|C %d|D: %d|E: %d|K: %d", buttonStatus.A,
					buttonStatus.B, buttonStatus.C, buttonStatus.D,
					buttonStatus.E, buttonStatus.K);

			// Print string of joystick values
			gdispDrawString(0, 11, str, font1, Black);

			// Draw Circle in center of square, add joystick movement
			circlePositionX = caveX + buttonStatus.joystick.x / 2;
			circlePositionY = caveY + buttonStatus.joystick.y / 2;
			gdispFillCircle(circlePositionX, circlePositionY, 10, Green);
		}
	}
}

void drawTask2(void * params) {
	char str[3][70] = { "PAUSED", "can you see the problem when",
			"you have no button debouncing?" }; // buffer for messages to draw to display
	struct buttons buttonStatus; // joystick queue input buffer
	const unsigned char next_state_signal = PREV_TASK;

	while (1) {
		if (xSemaphoreTake(DrawReady, portMAX_DELAY) == pdTRUE) { // Block until screen is ready

			while (xQueueReceive(ButtonQueue, &buttonStatus, 0) == pdTRUE)
				;

			// State machine input
			if (buttonStatus.E)
				xQueueSend(StateQueue, &next_state_signal, 100);

            // Clear background
		    gdispClear(White);

			for (unsigned char i = 0; i < 3; i++)
				gdispDrawString(PAUSED_TEXT_X(str[i]), PAUSED_TEXT_Y(i), str[i],
						font1, Black);
		}
	}
}

/**
 * This task polls the joystick value every 20 ticks
 */
void checkButtons(void * params) {
	TickType_t xLastWakeTime;
	xLastWakeTime = xTaskGetTickCount();
	struct buttons buttonStatus = { { 0 } };
	const TickType_t PollingRate = 20;

	while (TRUE) {
		// Remember last joystick values
		buttonStatus.joystick.x = (uint8_t)(
				ADC_GetConversionValue(ESPL_ADC_Joystick_2) >> 4);
		buttonStatus.joystick.y = (uint8_t) 255
				- (ADC_GetConversionValue(ESPL_ADC_Joystick_1) >> 4);

		// Buttons not debounced, delaying does not count as debouncing
		buttonStatus.A = !GPIO_ReadInputDataBit(ESPL_Register_Button_A,
		ESPL_Pin_Button_A);
		buttonStatus.B = !GPIO_ReadInputDataBit(ESPL_Register_Button_B,
		ESPL_Pin_Button_B);
		buttonStatus.C = !GPIO_ReadInputDataBit(ESPL_Register_Button_C,
		ESPL_Pin_Button_C);
		buttonStatus.D = !GPIO_ReadInputDataBit(ESPL_Register_Button_D,
		ESPL_Pin_Button_D);
		buttonStatus.E = !GPIO_ReadInputDataBit(ESPL_Register_Button_E,
		ESPL_Pin_Button_E);
		buttonStatus.K = !GPIO_ReadInputDataBit(ESPL_Register_Button_K,
		ESPL_Pin_Button_K);

		xQueueSend(ButtonQueue, &buttonStatus, 100);

		// Execute every 20 Ticks
		vTaskDelayUntil(&xLastWakeTime, PollingRate);
	}
}

/**
 * Example function to send data over UART
 *
 * Sends coordinates of a given position via UART.
 * Structure of a package:
 *  8 bit start byte
 *  8 bit x-coordinate
 *  8 bit y-coordinate
 *  8 bit checksum (= x-coord XOR y-coord)
 *  8 bit stop byte
 */
void sendPosition(struct buttons buttonStatus) {
	const uint8_t checksum = buttonStatus.joystick.x ^ buttonStatus.joystick.y
			^ buttonStatus.A ^ buttonStatus.B ^ buttonStatus.C ^ buttonStatus.D
			^ buttonStatus.E ^ buttonStatus.K;

	UART_SendData(startByte);
	UART_SendData(buttonStatus.joystick.x);
	UART_SendData(buttonStatus.joystick.y);
	UART_SendData(buttonStatus.A);
	UART_SendData(buttonStatus.B);
	UART_SendData(buttonStatus.C);
	UART_SendData(buttonStatus.D);
	UART_SendData(buttonStatus.E);
	UART_SendData(buttonStatus.K);
	UART_SendData(checksum);
	UART_SendData(stopByte);
}

/**
 * Example how to receive data over UART (see protocol above)
 */
void uartReceive() {
	char input;
	uint8_t pos = 0;
	char checksum;
	char buffer[11]; // Start byte,4* line byte, checksum (all xor), End byte
	struct buttons buttonStatus = { { 0 } };
	while (TRUE) {
		// wait for data in queue
		xQueueReceive(ESPL_RxQueue, &input, portMAX_DELAY);

		// decode package by buffer position
		switch (pos) {
		// start byte
		case 0:
			if (input != startByte)
				break;
		case 1:
		case 2:
		case 3:
		case 4:
		case 5:
		case 6:
		case 7:
		case 8:
		case 9:
			// read received data in buffer
			buffer[pos] = input;
			pos++;
			break;
		case 10:
			// Check if package is corrupted
			checksum = buffer[1] ^ buffer[2] ^ buffer[3] ^ buffer[4] ^ buffer[5]
					^ buffer[6] ^ buffer[7] ^ buffer[8];
			if (input == stopByte || checksum == buffer[9]) {
				// pass position to Joystick Queue
				buttonStatus.joystick.x = buffer[1];
				buttonStatus.joystick.y = buffer[2];
				buttonStatus.A = buffer[3];
				buttonStatus.B = buffer[4];
				buttonStatus.C = buffer[5];
				buttonStatus.D = buffer[6];
				buttonStatus.E = buffer[7];
				buttonStatus.K = buffer[8];
				xQueueSend(ButtonQueue, &buttonStatus, 100);
			}
			pos = 0;
		}
	}
}

/*
 *  Hook definitions needed for FreeRTOS to function.
 */
void vApplicationIdleHook() {
	while (TRUE) {
	};
}

void vApplicationMallocFailedHook() {
	while (TRUE) {
	};
}
