#!/bin/bash

# We don't have full control because of dbus
# Best effort to allow stopping and restarting

trap cleanup EXIT

SERVICE_NAME="KDE Plasma Desktop"

function cleanup() {
    kill $(jobs -p) > /dev/null 2>&1 &
    wait -n
    pkill plasma_session > /dev/null 2>&1
    pkill plasmashell > /dev/null 2>&1
    rm -rf /tmp/.X*
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
    
    # Start X server
    pkill Xvfb
    rm -rf /tmp/.X
    
    /usr/bin/Xvfb \
        "${DISPLAY:-:0}" \
        -ac \
        -screen "0" "8192x4096x${CDEPTH:-24}" \
        -dpi "${DPI:-96}" \
        +extension "RANDR" \
        +extension "GLX" \
        +iglx \
        +extension \
        "MIT-SHM" \
        +render \
        -nolisten "tcp" \
        -noreset \
        -shmem &
    
    # Kill some processes that hang around (for restart)
    pkill plasma_session > /dev/null 2>&1
    pkill plasmashell > /dev/null 2>&1
    
    rm -rf /root/.cache
    rm -rf /home/${USER_NAME}/.cache
    rm -rf /tmp/runtime-user
    mkdir -pm700 /tmp/runtime-user
    chown ${USER_NAME}:${USER_NAME} /tmp/runtime-user
    
    until [ -S "/tmp/.X11-unix/X${DISPLAY/:/}" ]; do
        printf "Waiting for X11 socket...\n"
        sleep 1
    done
    
    # Start KDE
    # Use VirtualGL to run the KDE desktop environment with OpenGL if the GPU is available, otherwise use OpenGL with llvmpipe
    export VGL_DISPLAY="${VGL_DISPLAY:-egl}"
        export VGL_REFRESHRATE="$REFRESH"
        su - $USER_NAME -w VirtualGL VGL_DISPLAY -c \
            '/usr/bin/vglrun +wm /usr/bin/dbus-launch --exit-with-session /usr/bin/startplasma-x11' &
    
    wait
}

start 2>&1