#!/usr/bin/env bash

docker build . -t stm32-cmake-stefaneicher_build

docker run -i --rm --net=host  \
--volume $PWD:/$PWD \
stm32-cmake-stefaneicher_build \
bash \
-c "cd /$PWD && ./buildStm32l152RE.sh && ./buildStm32F411RE.sh" \
