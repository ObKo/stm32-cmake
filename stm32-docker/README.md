## Using docker image

Example for compiling STM32F1 using the docker image [stm32-cmake](https://hub.docker.com/repository/docker/cortesja/stm32-cmake).

## How to use

Update `compile.sh` selecting your target device and device drivers and launch sh scripts with docker run at docker folder.

### Examples

The only difference is the syntax to share current directory ( `${PWD}` or `$(pwd)` ).

Windows

`docker run --rm -v ${PWD}:/home/stm32/ws cortesja/stm32-cmake:latest bash -c "sh docker/compile.sh`

 Linux

`docker run --rm -v $(pwd):/home/stm32/ws cortesja/stm32-cmake:latest bash -c "sh docker/compile.sh"`
