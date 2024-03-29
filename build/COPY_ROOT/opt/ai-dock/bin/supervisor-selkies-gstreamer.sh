#!/bin/bash

trap cleanup EXIT

LISTEN_PORT=${WEBRTC_PORT_LOCAL:-16100}
METRICS_PORT=${WEBRTC_METRICS_PORT:-26100}
PROXY_PORT=${WEBRTC_PORT_HOST:-6100}
SERVICE_URL="${WEBRTC_URL:-}"
QUICKTUNNELS=true
SERVICE_NAME="KDE Plasma Desktop (WebRTC)"

function cleanup() {
    rm -f /run/http_ports/$PROXY_PORT
    fuser -k -SIGTERM ${LISTEN_PORT}/tcp > /dev/null 2>&1 &
    wait -n
}

# todo improve this
function start() {
    source /opt/ai-dock/etc/environment.sh
    
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
        --arg service_url "${SERVICE_URL}" \
        '$ARGS.named'
    )"
    
    printf "%s\n" "$file_content" > /run/http_ports/$PROXY_PORT
    
    fuser -k -SIGKILL ${LISTEN_PORT}/tcp > /dev/null 2>&1 &
    wait -n

    /usr/bin/python3 /opt/ai-dock/fastapi/logviewer/main.py \
        -p $LISTEN_PORT \
        -r 5 \
        -s "${SERVICE_NAME}" \
        -t "Preparing ${SERVICE_NAME}" &
    fastapi_pid=$!
    
    while [[ -f /run/workspace_sync || -f /run/container_config || ! -S /run/dbus/system_bus_socket || ! -S "/tmp/.X11-unix/X${DISPLAY/:/}" ]]; do
        printf "Waiting for X11 and container provisioning...\n"
        sleep 1
    done
    
    kill $fastapi_pid &
    wait -n

    printf "Starting ${SERVICE_NAME}...\n"
    source /opt/ai-dock/etc/environment.sh
    
    sudo mkdir -pm755 /dev/input
    sudo touch /dev/input/{js0,js1,js2,js3}
    
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
    rm -rf ~/.cache/gstreamer-1.0
    
    # Start the selkies-gstreamer WebRTC HTML5 remote desktop application
   
    source /opt/gstreamer/gst-env
    selkies-gstreamer-resize ${SIZEW}x${SIZEH}
    
    if [[ ${ENABLE_COTURN,,} == "true" ]]; then
        export TURN_HOST="${TURN_HOST:-${EXTERNAL_IP_ADDRESS}}"
        export TURN_PORT="${COTURN_PORT_HOST:-3478}"
        export TURN_USERNAME="${COTURN_USER:-user}"
        export TURN_PASSWORD="${COTURN_PASSWORD:-password}"
    fi
    
    export LD_PRELOAD=/usr/local/lib/selkies-js-interposer/joystick_interposer.so${LD_PRELOAD:+:${LD_PRELOAD}}
    
    selkies-gstreamer \
        --enable_basic_auth=false \
        --addr="127.0.0.1" \
        --port="${LISTEN_PORT}" \
        --metrics_port=26105 $WEBRTC_FLAGS
}

start 2>&1