#!/bin/bash

# Defer to init to control dbus.

SERVICE_NAME=dbus

trap cleanup EXIT

function cleanup() {
    pkill dbus-daemon
    kill $(jobs -p) > /dev/null 2>&1
    rm -rf "$XDG_RUNTIME_DIR"
    wait -n
}

# todo improve this
function start() {
    source /opt/ai-dock/etc/environment.sh
    if [[ ${SERVERLESS,,} = "true" ]]; then
        printf "Refusing to start $SERVICE_NAME in serverless mode\n"
        exec sleep 10
    fi
    
    printf "Starting %s...\n" "$SERVICE_NAME"
    
    mkdir -pm700 "$XDG_RUNTIME_DIR"
    chown $(id -u):$(id -u) "$XDG_RUNTIME_DIR"

    dbus-daemon --session --nosyslog --address="$DBUS_SESSION_BUS_ADDRESS" --nofork
    
    sleep infinity
}


start 2>&1