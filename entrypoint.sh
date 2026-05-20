#!/bin/bash


# Copy pre-built tools from the image to the host mounted output directory
echo "Copying built tools to /output, mapped to $OUTPUT_HOST_DIR on the host"
if [ -d "/opt/installed_tools" ]; then
    cp -r /opt/installed_tools/* /output/
    echo "Tools copied successfully."
else
    echo "Warning: /opt/installed_tools not found in image. Run 'make build' before 'make run'."
fi
