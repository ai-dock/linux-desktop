#!/bin/false

# This file will be sourced in init.sh

function preflight_main() {
    # Normalize environment variables - Selkies v1.6 improved the naming
    # Ensure backwards compatibility with older templates/compose files - We will remove this eventually
    sync_vars DISPLAY_SIZEW SIZEW
    sync_vars DISPLAY_SIZEW SIZEH
    sync_vars DISPLAY_REFRESH REFRESH
    sync_vars DISPLAY_DPI DPI
    sync_vars DISPLAY_CDEPTH CDEPTH
    sync_vars_with_prefixes "SELKIES_" "WEBRTC_"
    sync_vars SELKIES_TURN_PROTOCOL TURN_PROTOCOL
    sync_vars SELKIES_TURN_PROTOCOL TURN_PROTOCOL
    sync_vars SELKIES_TURN_HOST TURN_HOST
    sync_vars SELKIES_TURN_PORT TURN_PORT
    sync_vars SELKIES_TURN_USERNAME TURN_USERNAME
    sync_vars SELKIES_TURN_PASSWORD TURN_PASSWORD

    export DBUS_SOCKET="${XDG_RUNTIME_DIR:-/tmp}/dbus-session-${DISPLAY#*:}"
    env-store DBUS_SOCKET
    export DBUS_SESSION_BUS_ADDRESS="unix:path=${DBUS_SOCKET}"
    env-store DBUS_SESSION_BUS_ADDRESS
    export XDG_SESSION_ID="${DISPLAY#*:}"
    env-store XDG_SESSION_ID
    export PIPEWIRE_RUNTIME_DIR="${PIPEWIRE_RUNTIME_DIR:-${XDG_RUNTIME_DIR:-/tmp}}"
    env-store PIPEWIRE_RUNTIME_DIR
    export PULSE_RUNTIME_PATH="${PULSE_RUNTIME_PATH:-${XDG_RUNTIME_DIR:-/tmp}/pulse}"
    env-store PULSE_RUNTIME_PATH
    export PULSE_SERVER="${PULSE_SERVER:-unix:${PULSE_RUNTIME_PATH:-${XDG_RUNTIME_DIR:-/tmp}/pulse}/native}"
    env-store PULSE_SERVER
    
    rm -rf $XDG_RUNTIME_DIR
    
    home_dir="/home/${USER_NAME}"
    desktop_dir="${home_dir}/Desktop"
    mkdir -p ${desktop_dir}
    chown ${USER_NAME}.${USER_NAME} "${desktop_dir}"
    ln -sf "${home_dir}" "${desktop_dir}"
    ln -sf "${WORKSPACE}" "${desktop_dir}"
    locale-gen $LANG
}


function sync_vars() {
    local var1_name=$1
    local var2_name=$2

    # Get the values of the environment variables
    local var1_value=$(eval echo "\$$var1_name")
    local var2_value=$(eval echo "\$$var2_name")

    # Synchronize the variables
    if [ -z "$var1_value" ]; then
        export $var1_name="$var2_value"
        env-store $var1_name
    elif [ -z "$var2_value" ]; then
        export $var2_name="$var1_value"
        env-store $var2_name
    fi
}

sync_vars_with_prefixes() {
    local prefix1=$1
    local prefix2=$2

    # Iterate over all environment variables matching the given prefixes
    for var in $(env | awk -F= '{print $1}' | grep -E "^($prefix1|$prefix2)"); do
        if [[ $var == ${prefix1}* ]]; then
            # Extract the variable name suffix (e.g., FOO from PREFIX1_FOO)
            suffix=${var#$prefix1}
            var1_name="${prefix1}${suffix}"
            var2_name="${prefix2}${suffix}"
        elif [[ $var == ${prefix2}* ]]; then
            # Extract the variable name suffix (e.g., FOO from PREFIX2_FOO)
            suffix=${var#$prefix2}
            var1_name="${prefix1}${suffix}"
            var2_name="${prefix2}${suffix}"
        fi

        # Get the values of the environment variables
        var1_value=$(eval echo "\$$var1_name")
        var2_value=$(eval echo "\$$var2_name")

        # Synchronize the variables
        if [ -z "$var1_value" ]; then
            export $var1_name="$var2_value"
            env-store $var1_name
        elif [ -z "$var2_value" ]; then
            export $var2_name="$var1_value"
            env-store $var2_name
        fi
    done
}



preflight_main "$@"