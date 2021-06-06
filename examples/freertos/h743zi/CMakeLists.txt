cmake_minimum_required(VERSION 3.13)
set(TARGET_NAME stm32-freertos)
set(STM32_CMAKE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../..)

# This must come before the project call!
set(CMAKE_TOOLCHAIN_FILE ${STM32_CMAKE_PATHT}/cmake/stm32_gcc.cmake)
project(${TARGET_NAME} CXX C ASM)
set(CMAKE_INCLUDE_CURRENT_DIR TRUE)

# Can be used to print out all devices for the H7 family
# include(${STM32_CMAKE_PATH}/cmake/stm32/devices.cmake)
# stm32_print_devices_by_family(FAMILY H7)

find_package(CMSIS COMPONENTS STM32H743ZI STM32H7_M7 REQUIRED)
find_package(HAL COMPONENTS STM32H7M7 STM32H743ZI RCC GPIO CORTEX REQUIRED)
find_package(FreeRTOS COMPONENTS ARM_CM7 REQUIRED)

add_executable(${TARGET_NAME})

target_sources(${TARGET_NAME} PRIVATE
    main.cpp
)

# This is required because FreeRTOSConfig.h and stm32hxx_hal_conf.h
# need to be included
target_include_directories(${TARGET_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(stm32-freertos PRIVATE
    FreeRTOS::Timers
    FreeRTOS::Heap::4
    FreeRTOS::ARM_CM7 
    HAL::STM32::H7::M7::RCC
    HAL::STM32::H7::M7::GPIO
    HAL::STM32::H7::M7::CORTEX
    CMSIS::STM32::H743ZI::M7
    STM32::NoSys
)

# Generate a binary file which allows flashing the STM32 board via drag-and-drop
add_custom_command(
	TARGET ${TARGET_NAME}
	POST_BUILD
	COMMAND echo Generating binary file ${CMAKE_PROJECT_NAME}.bin..
	COMMAND ${CMAKE_OBJCOPY} -O binary ${TARGET_NAME}.elf ${TARGET_NAME}.bin
)
