# OpenHW EDA Tools Builder

This project provides a containerized environment to build and deploy a suite of open-source EDA tools to a RHEL 9 compatible Linux environment. Instead of installing complex dependencies directly on your host machine, this project uses a Podman container to compile the tools and copy the binaries to your host system.

## Featured tools

The builder currently supports the following tools:
- **Verilator**: Verilog/SystemVerilog simulator. (TODO: SystemC support is currently not working)
- **Yosys**: Framework for RTL synthesis, simulation and formal verification.
- **RISC-V GNU Toolchain**: Compiler and toolchain for RISC-V architectures. (Currently builds `riscv32-unknown-elf` with `rv32imc` architecture and `ilp32` soft-float ABI).
- **Spike**: RISC-V ISA Simulator.
- **SystemC**: C++ library for system-level modeling.
- **cvc5**: SMT solver.

### Upcoming tools
- [ ] **Verible**: Integration is planned but currently not working.
- [ ] **Verilator + SystemC**: Fix integration between Verilator and SystemC.

## Prerequisites

- **RHEL 9** compatible Linux distribution, such as Red Hat Enterprise Linux 9 or Rocky Linux 9.
- **Podman** (or Docker) installed and configured.
- **Make** installed on the host system.

## Quick start

A quick way to use this project is to execute the command below on your terminal. It will produce the built EDA tools on the directory `eda_tools` of your home folder.
```bash
make all
```

### 1. Build the tools image
The build process is slow as it compiles several large projects from source. Run the following command to build the container image:

```bash
make build
```

You can customize the versions of the tools by passing variables to the make command:
```bash
make build VERILATOR_VERSIONS="v5.048" YOSYS_VERSIONS="0.65"
```

### 2. Deploy Tools to Host
Once the image is built, you can run the container to copy the compiled binaries to your host machine (default location: `~/eda_tools`):

```bash
make run
```

The `make run` command will:
1. Create the output directory on your host.
2. Start a container.
3. Copy the binaries from `/opt/installed_tools` inside the container to the mapped host directory.


## Project Structure

- `Containerfile`: Defines the build environment, dependencies (Rocky Linux 9), and compilation steps for each tool.
- `Makefile`: Provides a convenient interface to build and run the container.
- `entrypoint.sh`: Script executed when the container runs to copy the built tools to the output directory.
- `setup_env.sh`: Environment setup script.

## Customization

To change the default installation directory on your host, modify the `OUTPUT_HOST_DIR` variable in the `Makefile`:

```makefile
OUTPUT_HOST_DIR = /your/custom/path
```

