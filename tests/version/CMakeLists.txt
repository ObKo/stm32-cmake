cmake_minimum_required(VERSION 3.16)
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/stm32_gcc.cmake)


project(find-package-version C ASM)

stm32_fetch_cmsis(G4)
stm32_fetch_hal(G4)

find_package(CMSIS 1.2.1 COMPONENTS STM32G474CE REQUIRED )
find_package(HAL 1.2.2 COMPONENTS STM32G4 REQUIRED)

set(PROJECT_SOURCES
    main.c
)

add_executable(stm32-fetch-g4 ${PROJECT_SOURCES})
target_link_libraries(stm32-fetch-g4 CMSIS::STM32::G474CE STM32::NoSys)
stm32_print_size_of_target(stm32-fetch-g4)

