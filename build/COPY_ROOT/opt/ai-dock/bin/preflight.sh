#!/bin/false

# This file will be sourced in init.sh

function preflight_main() {
    if [[ -z $COTURN_PASSWORD ]]; then
        export COTURN_PASSWORD="auto_$(openssl rand -base64 8)"
        env-store COTURN_PASSWORD
    fi
}

preflight_main "$@"