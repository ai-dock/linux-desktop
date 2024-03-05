mkdir -p /opt/ai-dock/lib/steam-native

steam_dir="${home_dir}/.steam/debian-installation/"
proton_compat_dir="${steam_dir}/compatibilitytools.d/"
proton_dir="/opt/proton/${GE_PROTON_VERSION}"

mkdir -p "${proton_compat_dir}"
ln -s "${proton_dir}" "${proton_compat_dir}/${GE_PROTON_VERSION}"