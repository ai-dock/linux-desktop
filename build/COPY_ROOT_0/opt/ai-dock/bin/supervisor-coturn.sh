#!/bin/bash

trap cleanup EXIT

SERVICE_NAME="Coturn"
LISTEN_PORT="${COTURN_PORT_HOST:-3478}"
COTURN_LISTEN_ADDRESS=${COTURN_LISTEN_ADDRESS:-$(/opt/ai-dock/bin/external-ip-address)}

function cleanup() {
    fuser -k -SIGTERM ${LISTEN_PORT}/tcp > /dev/null 2>&1 &
    wait -n
}

function start() {
    cleanup
    source /opt/ai-dock/etc/environment.sh
    if [[ ${SERVERLESS,,} = "true" ]]; then
        printf "Refusing to start $SERVICE_NAME in serverless mode\n"
        exec sleep 10
    fi
    
    if [[ ${ENABLE_COTURN,,} != "true" ]]; then
        printf "Refusing to start $SERVICE_NAME without ENABLE_COTURN=true\n"
        exec sleep 10
    fi
    
    fuser -k -SIGKILL ${LISTEN_PORT}/tcp > /dev/null 2>&1 &
    printf "Starting ${SERVICE_NAME}...\n"
    turnserver \
        -n \
        -a \
        --log-file=stdout \
        --lt-cred-mech \
        --fingerprint \
        --no-stun \
        --no-multicast-peers \
        --no-cli \
        --no-tlsv1 \
        --no-tlsv1_1 \
        --realm="ai-dock.org" \
        --user="${COTURN_USER:-user}:${COTURN_PASSWORD:-password}" \
        -p "${LISTEN_PORT}" \
        -X "${COTURN_LISTEN_ADDRESS}" ${COTURN_FLAGS}
}

start 2>&1