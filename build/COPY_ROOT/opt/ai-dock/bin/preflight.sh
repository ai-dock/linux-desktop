#!/bin/false

# This file will be sourced in init.sh

function preflight_main() {
    if [[ -z $COTURN_PASSWORD ]]; then
        export COTURN_PASSWORD="auto_$(openssl rand -base64 8)"
        env-store COTURN_PASSWORD
    fi
    
    desktop_dir="${WORKSPACE}/home/${USER_NAME}/Desktop"
    mkdir -p ${desktop_dir}
    chown ${USER_NAME}.${USER_NAME} "${desktop_dir}"
    ln -sf "${WORKSPACE}" "${desktop_dir}"
    
    locale-gen $LANG
}

preflight_main "$@"