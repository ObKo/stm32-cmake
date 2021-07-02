#if defined STM32G0
    #include <stm32g0xx_hal.h>
#endif

#include <SEGGER_RTT.h>

void SysTick_Handler(void)
{
    HAL_IncTick();
}

int main(void)
{
    HAL_Init();
    HAL_SYSTICK_Config(SystemCoreClock / 1000);

    SEGGER_RTT_Init();
    SEGGER_RTT_printf(0, "SEGGER_RTT_printf() example time: %s, date: %s\r\n", __TIME__, __DATE__);

    uint32_t timeElapsedSeconds = 0;

    while (1)
    {
        HAL_Delay(1000);
        SEGGER_RTT_printf(0, "Time elapsed: %d\r\n", ++timeElapsedSeconds);
    }

    return 0;
}
