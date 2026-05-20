#!/usr/bin/env bash

# Example EDA tools setup script
# ==============================

# Directory where the built tools are located. 
# Use the same value used for the `make run` targets.
OUTPUT_HOST_DIR=$HOME/eda_tools

# Versions of the tools used on this example setup script
VERILATOR_VERSION="v5.048"
VERIBLE_VERSION="v0.0-4053-g89d4d98a"
YOSYS_VERSION="0.65"

### Verilator:
export VERILATOR_ROOT=$OUTPUT_HOST_DIR/verilator/$VERILATOR_VERSION/usr/local/share/verilator
export PATH=$VERILATOR_ROOT/bin:$PATH


### RISC-V GCC toolchain and Spike

# export CV_SW_TOOLCHAIN=/opt/riscv
export CV_SW_TOOLCHAIN=$OUTPUT_HOST_DIR/riscv
export PATH=$CV_SW_TOOLCHAIN/bin:$PATH


### Yosys
export PATH=$OUTPUT_HOST_DIR/yosys/$YOSYS_VERSION/usr/local/bin/:$PATH