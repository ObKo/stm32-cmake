#!/bin/sh

cd stm32-blinky

rm -rf cmake-build-debug_L152RE
mkdir cmake-build-debug_L152RE

cd cmake-build-debug_L152RE || exit

cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/arm_gcc_stm32f411RE.cmake -G "CodeBlocks - Unix Makefiles" ..

#cmake --build . --target all -- -j 4
cmake --build . --target stm32-blinky -- -j 4
cmake --build . --target stm32-blinky.bin -- -j 4
cmake --build . --target stm32-blinky.hex -- -j 4
cmake --build . --target stm32-blinky.dump -- -j 4
