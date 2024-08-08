#!/bin/bash

trap cleanup EXIT

SERVICE_NAME="Wireplumber"

function cleanup() {
    kill $(jobs -p) > /dev/null 2>&1
    wait -n
}

function start() {
    source /opt/ai-dock/etc/environment.sh
    if [[ ${SERVERLESS,,} = "true" ]]; then
        printf "Refusing to start $SERVICE_NAME in serverless mode\n"
        exec sleep 10
    fi
    
    printf "Starting ${SERVICE_NAME}...\n"
    
    until ls ${XDG_RUNTIME_DIR}/pipewire-*.lock >/dev/null 2>&1; do
        printf "Waiting for Pipewire lockfile...\n"
        sleep 1
    done

    source /opt/ai-dock/etc/environment.sh

    /usr/bin/wireplumber
}

start 2>&1