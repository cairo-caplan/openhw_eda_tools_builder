# Use Rocky Linux 9 as the base image
FROM rockylinux:9

# ARG VERILATOR_VERSIONS="v5.024,v5.026"
# ARG VERIBLE_VERSIONS="v0.0-2024-12-01"
# ARG YOSYS_VERSIONS="0.40,0.42"

ARG VERILATOR_VERSIONS=$VERILATOR_VERSIONS
ARG VERIBLE_VERSIONS=$VERIBLE_VERSIONS
ARG YOSYS_VERSIONS=$YOSYS_VERSIONS

# Install EPEL and enable CRB repository
RUN dnf -y install epel-release && \
    dnf -y config-manager --set-enabled crb

# Enable bazel repo, used by Verible
RUN dnf -y copr enable lihaohong/bazel

RUN dnf -y update && \
    dnf install -y --allowerasing \
        git \
        make \
        autoconf \
        gcc \
        gcc-c++ \
        flex \
        bison \
        perl \
        help2man \
        python3 \
        cmake \
        ninja-build \
        which \
        tar \
        gzip \
        patch \
        python3-pip \
        tcl-devel \
        readline-devel \
        gawk \
        graphviz \
        xz \
        bzip2 \
        diffutils \
        # Needed to extract cvc5 build
        unzip \
        # Optionals
        z3 \
        z3-devel \
        ccache \
        mold \
        numactl \
        jemalloc \
        jemalloc-devel \
        google-perftools-devel \
        gtkwave \
        libfl-static \
        zlib-devel \
        zlib-ng \
        zlib-ng-devel \
        clang \
        clang-devel \
        clang-tools-extra \
        git-clang-format \
        clang19-devel \
        clang19-tools-extra \
        git-clang-format19 \
        python3-clang \
        bear \
        gdb \
        graphviz \
        graphviz-devel \
        lcov \
        jq \
        jq-devel \
        libatomic \
        libatomic_ops \
        libatomic_ops-devel \
        libxcrypt \
        libxcrypt-devel \
        libxcrypt-compat \
        # (Optional) GCC 15
        gcc-toolset-15 \
        gcc-toolset-15-gcc-c++ \
        gcc-toolset-15-binutils \
        gcc-toolset-15-binutils-devel \
        gcc-toolset-15-binutils-gprofng \
        gcc-toolset-15-libatomic-devel \
        gcc-toolset-15-libstdc++-devel \
        #
        # Python 3.12, to be set by default instead of 3.9
        python3.12 \
        python3.12-pip \
        # For Verible
        bazel \
        # For the RISC-V GNU Toolchain
        autoconf \
        automake \
        python3 \
        libmpc-devel \
        mpfr-devel \
        gmp-devel \
        gawk \
        bison \
        flex \
        texinfo \
        patchutils \
        gcc \
        gcc-c++ \
        zlib-devel \
        expat-devel \
        libslirp-devel \
        ncurses-devel \
        expat-devel \
        libslirp-devel \
        ncurses-devel \
        dtc \
        && dnf clean all

# Set Python 3.12 as default
RUN alternatives --set python3 /usr/bin/python3.12 || \
    alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
    ln -sf /usr/bin/python3.12 /usr/bin/python

# Install cvc5 solver
RUN curl -L https://github.com/cvc5/cvc5/releases/download/cvc5-1.3.4/cvc5-Linux-x86_64-shared.zip -o /tmp/cvc5-Linux-x86_64-shared.zip && \
    unzip /tmp/cvc5-Linux-x86_64-shared.zip -d /usr/local && \
    rm /tmp/cvc5-Linux-x86_64-shared.zip

# Shared cache directory
ENV CACHE=/cache
RUN mkdir -p $CACHE

WORKDIR /src

# -----------------------------
# Build SystemC
# -----------------------------
RUN git clone https://github.com/accellera-official/systemc.git $CACHE/systemc || true
RUN source /opt/rh/gcc-toolset-15/enable && \
    cd $CACHE/systemc && \
    git checkout 2.3.3 && \
    mkdir -p build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) install

# -----------------------------
# Build Verilator
# -----------------------------
RUN git clone https://github.com/verilator/verilator.git $CACHE/verilator || true
RUN for v in $(echo $VERILATOR_VERSIONS | tr ',' ' '); do \
        echo "=== Building Verilator $v ==="; \
        source /opt/rh/gcc-toolset-15/enable; \
        cd $CACHE/verilator; \
        git fetch --all --tags; \
        git checkout $v; \
        autoconf; \
        gcc --version; \
        ./configure; \
        make -j$(nproc); \
        make install DESTDIR=/opt/installed_tools/verilator/$v; \
        done

# -----------------------------
# Build Verible
# -----------------------------
# RUN git clone https://github.com/chipsalliance/verible.git $CACHE/verible || true
# RUN for v in $(echo $VERIBLE_VERSIONS | tr ',' ' '); do \
#         echo "=== Building Verible $v ==="; \
#         source /opt/rh/gcc-toolset-15/enable; \
#         cd $CACHE/verible; \
#         git fetch --all --tags; \
#         git checkout $v; \
#         bazel --config=create_static_linked_executables --disk_cache=$CACHE/bazel-cache build -c opt //... ; \
#         mkdir -p /opt/installed_tools/verible/$v/bin; \
#         cp -r bazel-bin/* /opt/installed_tools/verible/$v/bin; \
#         done

# -----------------------------
# Build Yosys
# -----------------------------
RUN git clone https://github.com/YosysHQ/yosys.git $CACHE/yosys || true
RUN for v in $(echo $YOSYS_VERSIONS | tr ',' ' '); do \
        echo "=== Building Yosys $v ==="; \
        source /opt/rh/gcc-toolset-15/enable; \
        cd $CACHE/yosys; \
        git fetch --all --tags; \
        git checkout $v; \
        git submodule update --init --recursive; \
        make config-gcc; \
        make -j$(nproc); \
        make install DESTDIR=/opt/installed_tools/yosys/$v; \
        done

# -----------------------------
# Build RISC-V GNU Toolchain
# -----------------------------
RUN rm -Rf $CACHE/riscv-gnu-toolchain
RUN git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git $CACHE/riscv-gnu-toolchain || true
RUN source /opt/rh/gcc-toolset-15/enable && \
    cd $CACHE/riscv-gnu-toolchain && \
    ./configure --prefix=/opt/installed_tools/riscv --with-arch=rv32imc --with-abi=ilp32 && \
    make -j$(nproc)
# ./configure --prefix=/opt/installed_tools/riscv --with-arch=rv32gc --with-abi=ilp32d && \ 

# -----------------------------
# Build Spike RISC-V ISA Simulator
# -----------------------------
RUN git clone https://github.com/riscv-software-src/riscv-isa-sim.git $CACHE/riscv-isa-sim || true
RUN source /opt/rh/gcc-toolset-15/enable && \
    cd $CACHE/riscv-isa-sim && \
    ./configure --prefix=/opt/installed_tools/riscv && \
    make -j$(nproc) && \
    make install


# Create a user for the runner (GitHub runner cannot run as root)
RUN useradd -m runner
# USER runner
WORKDIR /home/runner

# Copy the initialization script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Run the entrypoint as container-root (UID 0) to set up iptables/socat first
ENTRYPOINT ["/entrypoint.sh"]