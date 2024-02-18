#!/bin/false

# This file will be sourced in init.sh

function preflight_main() {
    desktop_dir="${WORKSPACE}/home/${USER_NAME}/Desktop"
    mkdir -p ${desktop_dir}
    chown ${USER_NAME}.${USER_NAME} "${desktop_dir}"
    ln -sf "${WORKSPACE}" "${desktop_dir}"
    
    locale-gen $LANG
}

preflight_main "$@"