#!/usr/bin/env bash

docker build . -t stm32-cmake-stefaneicher_build
docker build . -f Dockerfile-Clion-Remote-Build-Image -t stm32-cmake-stefaneicher_clion_remote_build
#docker run --name build_daemon -d -p 7776:22 -p 7777:7777 -v $PWD:/app stm32-cmake-stefaneicher_clion_remote_build

docker run -i --rm --net=host  \
--volume $PWD:/$PWD \
stm32-cmake-stefaneicher_build \
bash \
-c "cd /$PWD && ./buildStm32l152RE.sh && ./buildStm32F411RE.sh" \
