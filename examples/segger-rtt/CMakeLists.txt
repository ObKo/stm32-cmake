cmake_minimum_required(VERSION 3.13)
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/stm32_gcc.cmake)

project(stm32-segger-rtt-g0 LANGUAGES C CXX ASM)

find_package(CMSIS COMPONENTS STM32G0 REQUIRED)
find_package(HAL COMPONENTS STM32G0 REQUIRED)

# NUCLEO-G071RB (STM32G071RB)
add_executable(stm32-segger-rtt-g0
    # RTT library
    RTT/SEGGER_RTT.c
    RTT/SEGGER_RTT_printf.c
    # Application
    main.c
    printf_gcc.c
)

target_link_libraries(stm32-segger-rtt-g0
    HAL::STM32::G0::RCC
    HAL::STM32::G0::GPIO
    HAL::STM32::G0::CORTEX
    CMSIS::STM32::G071RB
    STM32::NoSys
)

target_include_directories(stm32-segger-rtt-g0 PRIVATE
    # Source directory
    $<$<COMPILE_LANGUAGE:C,CXX>:${CMAKE_CURRENT_SOURCE_DIR}/>
    # RTT library
    $<$<COMPILE_LANGUAGE:C,CXX>:${CMAKE_CURRENT_SOURCE_DIR}/RTT>
)

stm32_print_size_of_target(stm32-segger-rtt-g0)
