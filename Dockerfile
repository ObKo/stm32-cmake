FROM ubuntu:18.04

# Configure apt and install packages
RUN apt-get update
#
RUN apt-get -y install apt-transport-https ca-certificates gnupg software-properties-common wget
#
#Add Repository from Original CMAKE Vendor
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add - \
    && add-apt-repository 'deb https://apt.kitware.com/ubuntu/ bionic main' 
#
#Update
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 
#
#Install C++ tools
RUN apt-get update && apt-get install -y \
    python3-pip \
    cmake \
	git-core \
	openocd \
	gdb \
    unzip 
#	
# Install STM32 toolchain
ARG TOOLCHAIN_TARBALL_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2"
ARG TOOLCHAIN_PATH=/opt/toolchain-arm
RUN mkdir -p ${TOOLCHAIN_PATH}
RUN wget ${TOOLCHAIN_TARBALL_URL} \
	&& export TOOLCHAIN_TARBALL_FILENAME=$(basename "${TOOLCHAIN_TARBALL_URL}") \
	&& tar -xvjf ${TOOLCHAIN_TARBALL_FILENAME} -C ${TOOLCHAIN_PATH} \
	&& rm -rf ${TOOLCHAIN_PATH}/share/doc \
	&& rm ${TOOLCHAIN_TARBALL_FILENAME}
#Set GCC-ARM
ENV PATH="${TOOLCHAIN_PATH}/gcc-arm-none-eabi-9-2019-q4-major/bin:${PATH}"
#	
# STM32F4 Sources
RUN mkdir -p /opt/stm32cubeF4
RUN cd /opt/stm32cubeF4 \
	&& git clone https://github.com/STMicroelectronics/STM32CubeF4.git . \
	&& git checkout v1.25.0 	
#
# Install Conan
RUN pip3 install conan
#
# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog