#!/bin/bash

trap cleanup EXIT

LISTEN_PORT=${VNC_PORT_LOCAL:-16200}
METRICS_PORT=${VNC_METRICS_PORT:-26200}
PROXY_PORT=${VNC_PORT_HOST:-6200}
SERVICE_URL="${VNC_URL:-}"
QUICKTUNNELS=true
SERVICE_NAME="KDE Plasma Desktop (VNC Fallback)"

function cleanup() {
    rm /run/http_ports/$PROXY_PORT > /dev/null 2>&1
    fuser -k -SIGTERM ${LISTEN_PORT}/tcp > /dev/null 2>&1 &
    wait -n
}

# todo improve this
function start() {
    source /opt/ai-dock/etc/environment.sh
    source /opt/ai-dock/bin/venv-set.sh serviceportal
    
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

    sudo cp -f /usr/share/kasmvnc/kasmvnc_defaults.yaml.template \
        /usr/share/kasmvnc/kasmvnc_defaults.yaml
    
    mkdir -p /home/${USER_NAME}/.vnc
    touch /home/${USER_NAME}/.vnc/.de-was-selected
    
    printf "%s\n%s\n" "$USER_PASSWORD" "$USER_PASSWORD" | vncpasswd -u $USER_NAME -w "/home/${USER_NAME}/.kasmpasswd"
    
    echo "" > "$HOME/.vnc/kasmvnc.yaml"
    yq -i "
        .command_line.prompt = false |
        .desktop.allow_resize = false |
        .desktop.pixel_depth = ${DISPLAY_CDEPTH} |
        .encoding.max_frame_rate = ${DISPLAY_REFRESH} |
        " "$HOME/.vnc/kasmvnc.yaml"
    #-geometry "${DISPLAY_SIZEW}x${DISPLAY_SIZEH}" \
        
    vncserver "${VNC_DISPLAY}" \
        -depth "${DISPLAY_CDEPTH}" \
        -fg \
        -noxstartup \
        -disableBasicAuth \
        -interface 127.0.0.1 \
        -websocketPort "${LISTEN_PORT}" \
        -desktop "VNC Proxy (${DISPLAY} on ${VNC_DISPLAY}"
      
    sleep infinity
}

start 2>&1