#!/bin/bash

SERVICE_NAME=dbus
PIDFILE=/run/dbus/pid

trap cleanup EXIT

function cleanup() {
    kill $(jobs -p) > /dev/null 2>&1
}

# todo improve this
function start() {
    if [[ ${SERVERLESS,,} = "true" ]]; then
        printf "Refusing to start $SERVICE_NAME in serverless mode\n"
        exec sleep 10
    fi
    
    printf "Starting %s...\n" "$SERVICE_NAME"
    mkdir -p /run/dbus
    chown messagebus.messagebus /run/dbus
    
    # Ensure it's not running
    if [[ -e $pidfile ]]; then
        start-stop-daemon \
          --stop \
          --retry 5 \
          --quiet \
          --oknodo \
          --pidfile $PIDFILE \
          --user messagebus > /dev/null 2>&1
    fi
    # Make really sure
    pkill dbus-daemon > /dev/null 2>&1
    rm -f $PIDFILE
    
    dbus-uuidgen --ensure
    
    exec start-stop-daemon \
        --start  \
        --pidfile $PIDFILE \
        --exec /usr/bin/dbus-daemon -- \
            --system \
            --nofork
}

start 2>&1