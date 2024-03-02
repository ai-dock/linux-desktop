#!/bin/false

# This file will be sourced in init.sh

function preflight_main() {
    home_dir="/home/${USER_NAME}"
    desktop_dir="${home_dir}/Desktop"
    mkdir -p ${desktop_dir}
    chown ${USER_NAME}.${USER_NAME} "${desktop_dir}"
    ln -sf "${home_dir}" "${desktop_dir}"
    ln -sf "${WORKSPACE}" "${desktop_dir}"
    locale-gen $LANG
}

preflight_main "$@"