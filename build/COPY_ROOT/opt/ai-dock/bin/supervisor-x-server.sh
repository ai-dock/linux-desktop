#!/bin/bash

# Run either an nvidia capable X server or an X proxy

trap cleanup EXIT

SERVICE_NAME="X Server"

function cleanup() {
    kill $(jobs -p) > /dev/null 2>&1 &
    wait -n
    sudo rm -rf /tmp/.X* /tmp/runtime-user ~/.cache
}

function start() {
    if [[ ${SERVERLESS,,} = "true" ]]; then
        printf "Refusing to start $SERVICE_NAME in serverless mode\n"
        exec sleep 10
    fi
    
    printf "Starting ${SERVICE_NAME}...\n"
    
    until [[ -S /run/dbus/system_bus_socket ]]; do
        printf "Waiting for dbus socket...\n"
        sleep 1
    done
    
    cleanup
    # This symbolic link enables running Xorg inside a container with `-sharevts`
    sudo ln -snf /dev/ptmx /dev/tty7
    sudo mkdir -pm700 /tmp/runtime-user
    sudo chown ${USER_NAME}:${USER_NAME} /tmp/runtime-user
    
    if [[ $XPU_TARGET == "NVIDIA_GPU"  && $(is_nvidia_capable) == "true" ]]; then
        printf "Starting NVIDIA X server...\n"
        export X_PROXY=false
        env-store X_PROXY
        start_nvidia
    else
        printf "Starting proxy X server...\n"
        export X_PROXY=true
        env-store X_PROXY
        start_proxy
    fi
}

function start_nvidia() {
    # Mostly copied from https://github.com/selkies-project/docker-nvidia-glx-desktop
    
    # Check if nvidia display drivers are present - Download if not
    if ! which nvidia-xconfig /dev/null 2>&1; then
        # Driver version is provided by the kernel through the container toolkit
        export DRIVER_ARCH="$(dpkg --print-architecture | sed -e 's/arm64/aarch64/'  -e 's/i.*86/x86/' -e 's/amd64/x86_64/' -e 's/unknown/x86_64/')"
        export DRIVER_VERSION="$(head -n1 </proc/driver/nvidia/version | awk '{print $8}')"
        # Download the correct nvidia driver (check multiple locations)
        cd /tmp
        curl -fsSL -O "https://international.download.nvidia.com/XFree86/Linux-${DRIVER_ARCH}/${DRIVER_VERSION}/NVIDIA-Linux-${DRIVER_ARCH}-${DRIVER_VERSION}.run" || curl -fsSL -O "https://international.download.nvidia.com/tesla/${DRIVER_VERSION}/NVIDIA-Linux-${DRIVER_ARCH}-${DRIVER_VERSION}.run" || { echo "Failed NVIDIA GPU driver download."; }
        
        if [ -f "/tmp/NVIDIA-Linux-${DRIVER_ARCH}-${DRIVER_VERSION}.run" ]; then
            # Extract installer before installing
            sudo sh "NVIDIA-Linux-${DRIVER_ARCH}-${DRIVER_VERSION}.run" -x
            cd "NVIDIA-Linux-${DRIVER_ARCH}-${DRIVER_VERSION}"
            # Run installation without the kernel modules and host components
            sudo ./nvidia-installer --silent \
                            --no-kernel-module \
                            --install-compat32-libs \
                            --no-nouveau-check \
                            --no-nvidia-modprobe \
                            --no-rpms \
                            --no-backup \
                            --no-check-for-alternate-installs
            sudo rm -rf /tmp/NVIDIA* && cd ~
        fi
    fi
    
    # Allow starting Xorg from a pseudoterminal instead of strictly on a tty console
    if [ ! -f /etc/X11/Xwrapper.config ]; then
        echo -e "allowed_users=anybody\nneeds_root_rights=yes" | sudo tee /etc/X11/Xwrapper.config > /dev/null
    fi
    if grep -Fxq "allowed_users=console" /etc/X11/Xwrapper.config; then
        sudo sed -i "s/allowed_users=console/allowed_users=anybody/;$ a needs_root_rights=yes" /etc/X11/Xwrapper.config
    fi
    
    # Remove existing Xorg configuration
    if [ -f "/etc/X11/xorg.conf" ]; then
        sudo rm -f "/etc/X11/xorg.conf"
    fi
    
    # Get first GPU device if all devices are available or `NVIDIA_VISIBLE_DEVICES` is not set
    if [ "$NVIDIA_VISIBLE_DEVICES" == "all" ] || [ -z "$NVIDIA_VISIBLE_DEVICES" ]; then
        export GPU_SELECT="$(sudo nvidia-smi --query-gpu=uuid --format=csv | sed -n 2p)"
        # Get first GPU device out of the visible devices in other situations
        else
        export GPU_SELECT="$(sudo nvidia-smi --id=$(echo "$NVIDIA_VISIBLE_DEVICES" | cut -d ',' -f1) --query-gpu=uuid --format=csv | sed -n 2p)"
        if [ -z "$GPU_SELECT" ]; then
        export GPU_SELECT="$(sudo nvidia-smi --query-gpu=uuid --format=csv | sed -n 2p)"
        fi
    fi
    
    # Test whether we have a GPU and display drivers. If not we fall back to Xvfb proxy and hope we have /dev/dri
    if [ -z "$GPU_SELECT" ] || ! which nvidia-xconfig > /dev/null 2>&1; then
        echo "No NVIDIA GPUs detected or nvidia-container-toolkit not configured. Starting X proxy."
        nv_capable=false
    fi

    if [[ $nv_capable != "false" ]]; then
        # Setting `VIDEO_PORT` to none disables RANDR/XRANDR, do not set this if using datacenter GPUs
        if [ "${VIDEO_PORT,,}" = "none" ]; then
            export CONNECTED_MONITOR="--use-display-device=None"
        # The X server is otherwise deliberately set to a specific video port despite not being plugged to enable RANDR/XRANDR, monitor will display the screen if plugged to the specific port
        else
            export CONNECTED_MONITOR="--connected-monitor=${VIDEO_PORT}"
        fi
        
        # Bus ID from nvidia-smi is in hexadecimal format, should be converted to decimal format which Xorg understands, required because nvidia-xconfig doesn't work as intended in a container
        HEX_ID="$(sudo nvidia-smi --query-gpu=pci.bus_id --id="$GPU_SELECT" --format=csv | sed -n 2p)"
        IFS=":." ARR_ID=($HEX_ID)
        unset IFS
        BUS_ID="PCI:$((16#${ARR_ID[1]})):$((16#${ARR_ID[2]})):$((16#${ARR_ID[3]}))"
        # A custom modeline should be generated because there is no monitor to fetch this information normally
        export MODELINE="$(cvt -r "${SIZEW}" "${SIZEH}" "${REFRESH}" | sed -n 2p)"
        # Generate /etc/X11/xorg.conf with nvidia-xconfig
        sudo nvidia-xconfig --virtual="${SIZEW}x${SIZEH}" --depth="$CDEPTH" --mode="$(echo "$MODELINE" | awk '{print $2}' | tr -d '\"')" --allow-empty-initial-configuration --no-probe-all-gpus --busid="$BUS_ID" --no-multigpu --no-sli --no-base-mosaic --only-one-x-screen ${CONNECTED_MONITOR}
        # Guarantee that the X server starts without a monitor by adding more options to the configuration
        sudo sed -i '/Driver\s\+"nvidia"/a\    Option         "ModeValidation" "NoMaxPClkCheck, NoEdidMaxPClkCheck, NoMaxSizeCheck, NoHorizSyncCheck, NoVertRefreshCheck, NoVirtualSizeCheck, NoExtendedGpuCapabilitiesCheck, NoTotalSizeCheck, NoDualLinkDVICheck, NoDisplayPortBandwidthCheck, AllowNon3DVisionModes, AllowNonHDMI3DModes, AllowNonEdidModes, NoEdidHDMI2Check, AllowDpInterlaced"\n    Option         "HardDPMS" "False"' /etc/X11/xorg.conf
        # Add custom generated modeline to the configuration
        sudo sed -i '/Section\s\+"Monitor"/a\    '"$MODELINE" /etc/X11/xorg.conf
        # Prevent interference between GPUs, add this to the host or other containers running Xorg as well
        echo -e "Section \"ServerFlags\"\n    Option \"AutoAddGPU\" \"false\"\nEndSection" | sudo tee -a /etc/X11/xorg.conf > /dev/null
        
        # Run Xorg server with required extensions
        echo "xorg" > /tmp/.X-mode
        /usr/bin/Xorg vt7 -noreset -novtswitch -sharevts -dpi "${DPI}" +extension "GLX" +extension "RANDR" +extension "RENDER" +extension "MIT-SHM" "${DISPLAY}" 
        
        # If everything is working as expected we won't reach this - But if we do we can still have a display
        export X_PROXY=forced
        env-store X_PROXY
        printf "Starting proxy X server (NVIDIA Failure)...\n"
        start_proxy
    else
        export X_PROXY=forced
        env-store X_PROXY
        printf "Starting proxy X server (No NVIDIA driver)...\n"
        start_proxy
    fi
}

# If /dev/dri is not available in te container we will have no HW accel
function start_proxy() {
    echo "proxy" > /tmp/.X-mode
    /usr/bin/Xvfb "${DISPLAY}" -ac -screen "0" "8192x4096x${CDEPTH}" -dpi "${DPI}" +extension "RANDR" +extension "GLX" +iglx +extension "MIT-SHM" +render -nolisten "tcp" -noreset -shmem
}

function is_nvidia_capable() {
    if which nvidia-smi > /dev/null 2>&1; then
        echo "true"
    else
        echo "false"
    fi
}


start 2>&1