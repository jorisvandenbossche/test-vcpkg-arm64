FROM arm64v8/almalinux:8

RUN dnf -y upgrade && dnf -y install dnf-plugins-core && dnf config-manager --set-enabled powertools
# building openssl needs IPC-Cmd (https://github.com/microsoft/vcpkg/issues/24988)
RUN dnf -y install gcc-toolset-12-binutils gcc-toolset-12-gcc gcc-toolset-12-gcc-c++ git python39 curl zip unzip tar ninja-build perl-IPC-Cmd

RUN python3 -m pip install pipx && export PIPX_BIN_DIR=/usr/local/bin && python3 -m pipx install cmake

ARG DEVTOOLSET_ROOTPATH=/opt/rh/gcc-toolset-12/root
ARG LD_LIBRARY_PATH_ARG=${DEVTOOLSET_ROOTPATH}/usr/lib64:${DEVTOOLSET_ROOTPATH}/usr/lib:${DEVTOOLSET_ROOTPATH}/usr/lib64/dyninst:${DEVTOOLSET_ROOTPATH}/usr/lib/dyninst
ARG PREPEND_PATH=${DEVTOOLSET_ROOTPATH}/usr/bin:

ENV DEVTOOLSET_ROOTPATH=${DEVTOOLSET_ROOTPATH}
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH_ARG}
ENV PATH=${PREPEND_PATH}${PATH}

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
