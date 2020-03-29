

set(CMAKE_BUILD_TYPE Debug )
set(TOOLCHAIN_PREFIX /opt/toolchain-arm/gcc-arm-none-eabi-9-2019-q4-major)
set(STM32Cube_DIR /opt/stm32cubeL1)
set(STM32_CHIP STM32L152RE)
set(STM32_FAMILY L1)
#set(CMAKE_TOOLCHAIN_FILE ../cmake/gcc_stm32.cmake)

include(/Users/stefaneicher/CLionProjects/stm32-cmake/cmake/gcc_stm32.cmake)
#include(../../cmake/gcc_stm32.cmake)
#include(../../cmake/gcc_stm32.cmake)