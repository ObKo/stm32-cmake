SET(CMAKE_MAKE_PROGRAM c:/MinGW32/bin/mingw32-make.exe CACHE FILEPATH "Make program")
SET(CMAKE_TOOLCHAIN_FILE "e:/github_c/stm32-cmake_mod/gcc_stm32.cmake" CACHE FILEPATH "Toolchain file")
SET(TOOLCHAIN_PREFIX "c:/Program Files (x86)/GNU Tools ARM Embedded/4.9 2015q1" CACHE PATH "Toolchain prefix")
#SET(TOOLCHAIN_PREFIX "c:/DAVEv4/DAVE-4.0.0/eclipse/ARM-GCC-49" CACHE PATH "Toolchain prefix")
SET(STM32_CHIP "STM32F103RB" CACHE STRING "stm32 chip")
#SET(STM32_CHIP "STM32F411RE" CACHE STRING "stm32 chip")
#SET(STM32F1_StdPeriphLib_DIR  "c:/workdir/libs/stm32/STM32F10x_StdPeriph_Lib_V3.5.0" CACHE PATH "StdPeriph path")
SET(CMAKE_INSTALL_PREFIX "e:/github_c/stm32-cmake/bin" CACHE PATH "Install prefix")
SET(CMAKE_MODULE_PATH "e:/github_c/stm32-cmake/cmake/Modules" CACHE PATH "CMake modules path")
SET(EXTRA_FIND_PATH "${CMAKE_INSTALL_PREFIX}" CACHE PATH "Build root path")
SET(CMAKE_ECLIPSE_VERSION "4.4" CACHE STRING "Eclipse version")



