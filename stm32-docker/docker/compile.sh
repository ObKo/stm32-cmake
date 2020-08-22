#!/bin/bash
set -e

if [ ! -d "build" ]; then
  mkdir build
fi
cd build

cmake -DSTM32_CHIP=STM32F100CB -DCMAKE_TOOLCHAIN_FILE=$STM32_CMAKE_MODULES/gcc_stm32.cmake -DTOOLCHAIN_PREFIX=$ARM_TOOLCHAIN -DCMAKE_BUILD_TYPE=Debug -DSTM32Cube_DIR=$STM32_FW_F1 ..

make