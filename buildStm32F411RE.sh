#!/bin/sh

cd stm32-blinky

rm -rf cmake-build-debug
mkdir cmake-build-debug

cd cmake-build-debug || exit

cmake -DCMAKE_BUILD_TYPE=Debug  \
-DTOOLCHAIN_PREFIX=/opt/toolchain-arm/gcc-arm-none-eabi-9-2019-q4-major \
-DSTM32Cube_DIR=/opt/stm32cubeF4 \
-DSTM32_CHIP=STM32F411RE \
-DSTM32_FAMILY=F4 \
-DCMAKE_TOOLCHAIN_FILE=../cmake/gcc_stm32.cmake \
-G "CodeBlocks - Unix Makefiles" ..

#cmake --build . --target all -- -j 4
cmake --build . --target stm32-blinky -- -j 4
cmake --build . --target stm32-blinky.bin -- -j 4
cmake --build . --target stm32-blinky.hex -- -j 4
cmake --build . --target stm32-blinky.dump -- -j 4
