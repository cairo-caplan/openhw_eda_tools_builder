IMAGE_NAME = eda_tools_builder_img
OUTPUT_HOST_DIR ?= ~/eda_tools

VERILATOR_VERSIONS?="v5.048"
VERIBLE_VERSIONS?="v0.0-4053-g89d4d98a"
YOSYS_VERSIONS?="0.65"

.PHONY: all build run

all: build run

# Build image and tools. A slow process.
build:
	podman build -t $(IMAGE_NAME) \
		--build-arg VERILATOR_VERSIONS=$(VERILATOR_VERSIONS) \
		--build-arg VERIBLE_VERSIONS=$(VERIBLE_VERSIONS) \
		--build-arg YOSYS_VERSIONS=$(YOSYS_VERSIONS) .

# Create and run container, copying the built tools to the host. A fast process.
run:
	mkdir -p $(OUTPUT_HOST_DIR)

	podman run --rm \
	-v $(OUTPUT_HOST_DIR):/output:z \
	--env 'OUTPUT_HOST_DIR=$(OUTPUT_HOST_DIR)' \
	$(IMAGE_NAME)
