#!/bin/bash

trap cleanup EXIT

LISTEN_PORT=${SELKIES_PORT_LOCAL:-18080}
METRICS_PORT=${SELKIES_METRICS_PORT:-28080}
PROXY_PORT=${SELKIES_PORT_HOST:-8080}
PROXY_SECURE=true
SERVICE_NAME="KDE Plasma Desktop (WebRTC)"

function cleanup() {
    kill $(jobs -p) > /dev/null 2>&1
    rm /run/http_ports/$PROXY_PORT > /dev/null 2>&1
}

# todo improve this
function start() {
    if [[ ${SERVERLESS,,} = "true" ]]; then
        printf "Refusing to start $SERVICE_NAME in serverless mode\n"
        exec sleep 10
    fi
    
    file_content="$(
      jq --null-input \
        --arg listen_port "${LISTEN_PORT}" \
        --arg metrics_port "${METRICS_PORT}" \
        --arg proxy_port "${PROXY_PORT}" \
        --arg proxy_secure "${PROXY_SECURE,,}" \
        --arg service_name "${SERVICE_NAME}" \
        '$ARGS.named'
    )"
    
    printf "%s\n" "$file_content" > /run/http_ports/$PROXY_PORT
    
    printf "Starting ${SERVICE_NAME}...\n"
    kill $(lsof -t -i:$LISTEN_PORT) > /dev/null 2>&1 &
    wait -n
    
    until [[ -S /run/dbus/system_bus_socket ]]; do
        printf "Waiting for dbus socket...\n"
        sleep 1
    done
    
    until [ -S "/tmp/.X11-unix/X${DISPLAY/:/}" ]; do
        printf "Waiting for X11 socket...\n"
        sleep 1
    done
    
    pkill selkies-gstreamer > /dev/null 2>&1 &
    wait
    
    mkdir -pm755 /dev/input
    touch /dev/input/{js0,js1,js2,js3}
    
    export PWA_APP_NAME="AI-Dock Desktop (selkies)"
    export PWA_APP_SHORT_NAME="desktop"
    export PWA_START_URL="/index.html"
    sed -i \
        -e "s|PWA_APP_NAME|${PWA_APP_NAME}|g" \
        -e "s|PWA_APP_SHORT_NAME|${PWA_APP_SHORT_NAME}|g" \
        -e "s|PWA_START_URL|${PWA_START_URL}|g" \
            /opt/gst-web/manifest.json && \
    sed -i \
        -e "s|PWA_CACHE|${PWA_APP_SHORT_NAME}-webrtc-pwa|g" \
            /opt/gst-web/sw.js

    # Clear the cache registry
    rm -rf /home/user/.cache/gstreamer-1.0
    
    # Start the selkies-gstreamer WebRTC HTML5 remote desktop application
    export LISTEN_PORT
    exec su - $USER_NAME -w LISTEN_PORT -c '\
        source /opt/gstreamer/gst-env && \
        export ENABLE_BASIC_AUTH=false && \
        /usr/local/bin/selkies-gstreamer-resize ${SIZEW}x${SIZEH} && \
        selkies-gstreamer --addr="127.0.0.1" --port="${LISTEN_PORT}" \
        '
}

start 2>&1