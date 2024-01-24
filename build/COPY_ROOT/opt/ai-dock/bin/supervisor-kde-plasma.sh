#!/bin/bash

# We don't have full control because of dbus
# Best effort to allow stopping and restarting

trap cleanup EXIT

SERVICE_NAME="KDE Plasma Desktop"

function cleanup() {
    sudo kill $(jobs -p) > /dev/null 2>&1 &
    wait -n
    # Cause X to restart, taking dependent processes with it
    sudo pkill supervisor-x-server > /dev/null 2>&1
    sudo pkill plasmashell > /dev/null 2>&1
}

function start() {
    source /opt/ai-dock/etc/environment.sh
    if [[ ${SERVERLESS,,} = "true" ]]; then
        printf "Refusing to start $SERVICE_NAME in serverless mode\n"
        exec sleep 10
    fi
    
    printf "Starting ${SERVICE_NAME}...\n"
    
    until [[ -S /run/dbus/system_bus_socket ]]; do
        printf "Waiting for dbus socket...\n"
        sleep 1
    done
    
    until [ -S "/tmp/.X11-unix/X${DISPLAY/:/}" ]; do
        printf "Waiting for X11 socket...\n"
        sleep 1
    done
    source /opt/ai-dock/etc/environment.sh
    
    rm -rf ~/.cache
  
    # Start KDE
    # Use VirtualGL to run the KDE desktop environment with OpenGL if the GPU is available, otherwise use OpenGL with llvmpipe
    xmode="$(cat /tmp/.X-mode)"
 
    if [[ $xmode == "proxy" ]]; then
        /usr/bin/vglrun \
            +wm \
            /usr/bin/dbus-launch \
                /usr/bin/startplasma-x11
    else
        /usr/bin/dbus-launch \
            /usr/bin/startplasma-x11
    fi
}

start 2>&1