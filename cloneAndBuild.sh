#!/usr/bin/env bash
if [ -n "$1" ]; then
  dir=$1
else
  dir=stm32-cmake
fi

rm -r $dir
git clone https://github.com/stefaneicher/stm32-cmake.git $dir
cd $dir

./build.sh