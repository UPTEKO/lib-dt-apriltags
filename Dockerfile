ARG PYTHON_VERSION="PYTHON_VERSION_NOT_SET"
ARG ARCH="ARCH_NOT_SET"

FROM ${ARCH}/ubuntu:22.04

ARG ARCH
ARG PYTHON_VERSION
ENV QEMU_EXECVE 1

# copy QEMU
COPY ./assets/qemu/${ARCH}/ /usr/bin/

# Set the environment variable to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Example installation command that might require user input
RUN apt-get update && apt-get install -y tzdata

# Optionally, set the timezone to a specific value
RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata

# install python and cmake
RUN apt-get update && \
  apt-get install -y \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-pip \
    cmake

# install cython (needed by bdist_wheel for numpy)
RUN pip${PYTHON_VERSION} install \
    cython

# install python libraries
RUN pip${PYTHON_VERSION} install \
    setuptools \
    numpy \
    bdist-wheel-name \
    wheel>=0.31.0

# install building script
COPY ./assets/build.sh /build.sh

# prepare environment
ENV ARCH=${ARCH}
ENV PYTHON_VERSION=${PYTHON_VERSION}
RUN mkdir /source
RUN mkdir /out
WORKDIR /source

# define command
CMD /build.sh
