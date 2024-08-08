#!/bin/false

# For CUDA specific logic

build_nvidia_main() {
    printf "/usr/local/nvidia/lib\n" >> /etc/ld.so.conf.d/nvidia.conf
    printf "/usr/local/nvidia/lib64\n" >> /etc/ld.so.conf.d/nvidia.conf

    # Install NVIDIA VAAPI driver
    $APT_INSTALL \
        libffmpeg-nvenc-dev
        
    NVIDIA_VAAPI_DRIVER_VERSION="$(curl -fsSL "https://api.github.com/repos/elFarto/nvidia-vaapi-driver/releases/latest" | jq -r '.tag_name' | sed 's/[^0-9\.\-]*//g')"
    cd /tmp
    curl -fsSL "https://github.com/elFarto/nvidia-vaapi-driver/archive/v${NVIDIA_VAAPI_DRIVER_VERSION}.tar.gz" | tar -xzf - 
    mv -f nvidia-vaapi-driver* nvidia-vaapi-driver
    cd nvidia-vaapi-driver
    meson setup build
    meson install -C build

    # Configure OpenCL manually
    mkdir -pm755 /etc/OpenCL/vendors
    printf "libnvidia-opencl.so.1\n" > /etc/OpenCL/vendors/nvidia.icd
    # Configure Vulkan manually
    VULKAN_API_VERSION=$(dpkg -s libvulkan1 | grep -oP 'Version: [0-9|\.]+' | grep -oP '[0-9]+(\.[0-9]+)(\.[0-9]+)')
    mkdir -pm755 /etc/vulkan/icd.d/ 
    cp /opt/ai-dock/share/vulkan/icd.d/nvidia_icd.json /etc/vulkan/icd.d/
    sed -i "s/\$VULKAN_API_VERSION/$VULKAN_API_VERSION/g" /etc/vulkan/icd.d/nvidia_icd.json
}

build_nvidia_main "$@"