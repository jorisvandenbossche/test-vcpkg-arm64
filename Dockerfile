FROM arm64v8/almalinux:8

# building openssl needs IPC-Cmd (https://github.com/microsoft/vcpkg/issues/24988)
RUN dnf -y install curl zip unzip tar ninja-build perl-IPC-Cmd

# require python >= 3.7 (python 3.6 is default on base image) for meson 
RUN ln -s /opt/python/cp38-cp38/bin/python3 /usr/bin/python3

RUN git clone https://github.com/Microsoft/vcpkg.git /opt/vcpkg

ENV VCPKG_INSTALLATION_ROOT="/opt/vcpkg"
ENV PATH="${PATH}:/opt/vcpkg"

# Must be set when building on arm
ENV VCPKG_FORCE_SYSTEM_BINARIES=1

# mkdir & touch -> workaround for https://github.com/microsoft/vcpkg/issues/27786
RUN bootstrap-vcpkg.sh && \
    mkdir -p /root/.vcpkg/ $HOME/.vcpkg && \
    touch /root/.vcpkg/vcpkg.path.txt $HOME/.vcpkg/vcpkg.path.txt && \
    vcpkg integrate install && \
    vcpkg integrate bash

# COPY arm64-linux-dynamic-release.cmake opt/vcpkg/custom-triplets/arm64-linux-dynamic-release.cmake

ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/vcpkg/installed/arm64-linux-dynamic-release/lib"
RUN vcpkg install pkgconf:arm64-linux && vcpkg list
