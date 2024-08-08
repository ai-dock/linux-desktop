#!/bin/bash

trap cleanup EXIT

LISTEN_PORT=${SELKIES_PORT_LOCAL:-16100}
METRICS_PORT=${SELKIES_METRICS_PORT:-26100}
PROXY_PORT=${SELKIES_PORT_HOST:-6100}
SERVICE_URL="${SELKIES_URL:-}"
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
    source /opt/ai-dock/bin/venv-set.sh serviceportal
    source /opt/ai-dock/bin/venv-set.sh selkies
    
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

    "$SERVICEPORTAL_VENV_PYTHON" /opt/ai-dock/fastapi/logviewer/main.py \
        -p $LISTEN_PORT \
        -r 5 \
        -s "${SERVICE_NAME}" \
        -t "Preparing ${SERVICE_NAME}" &
    fastapi_pid=$!
    
    while [[ -f /run/workspace_sync || -f /run/container_config || ! -S "$DBUS_SOCKET" || ! -S "/tmp/.X11-unix/X${DISPLAY/:/}" ]]; do
        printf "Waiting for X11 and container provisioning...\n"
        sleep 1
    done
    
    kill $fastapi_pid &
    wait -n

    printf "Starting ${SERVICE_NAME}...\n"
    
    source /opt/ai-dock/etc/environment.sh
    source "$SELKIES_VENV/bin/activate"
    
    sudo mkdir -pm755 /dev/input
    sudo touch /dev/input/{js0,js1,js2,js3}

    # Clear the cache registry
    rm -rf ~/.cache/gstreamer-1.0
    
    export GST_DEBUG="${GST_DEBUG:-*:2}"
    export GSTREAMER_PATH=/opt/gstreamer

    source "$GSTREAMER_PATH/gst-env"
    
    # Start the selkies-gstreamer WebRTC HTML5 remote desktop application
   
    selkies-gstreamer-resize ${DISPLAY_SIZEW}x${DISPLAY_SIZEH}
    
    if [[ ${ENABLE_COTURN,,} == "true" ]]; then
        export SELKIES_TURN_HOST="${SELKIES_TURN_HOST:-${EXTERNAL_IP_ADDRESS}}"
        export SELKIES_TURN_PORT="${COTURN_PORT_HOST:-3478}"
        export SELKIES_TURN_USERNAME="${COTURN_USER:-user}"
        export SELKIES_TURN_PASSWORD="${COTURN_PASSWORD:-password}"
    fi
    
    export SELKIES_INTERPOSER='/usr/$LIB/selkies_joystick_interposer.so'
    export LD_PRELOAD="${SELKIES_INTERPOSER}${LD_PRELOAD:+:${LD_PRELOAD}}"
    export LD_LIBRARY_PATH="/opt/gstreamer/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
    export SDL_JOYSTICK_DEVICE=/dev/input/js0
    
    selkies-gstreamer \
        --enable_basic_auth=false \
        --addr="127.0.0.1" \
        --port="${LISTEN_PORT}"
}

start 2>&1