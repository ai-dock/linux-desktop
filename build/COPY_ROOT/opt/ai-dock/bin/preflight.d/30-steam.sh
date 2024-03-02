mkdir -p /opt/ai-dock/lib/steam-native

steam_dir="${home_dir}"/.steam/debian-installation/
proton_compat_dir="${steam_dir}/compatibilitytools.d/${GE_PROTON_VERSION}"
proton_binary_path="/opt/proton/${GE_PROTON_VERSION}/proton"
mkdir -p "${proton_compat_dir}"
cp /opt/ai-dock/share/proton/* "${proton_compat_dir}"
sed -i "s#PROTON_NAME#${GE_PROTON_VERSION}#g" "${proton_compat_dir}/compatibilitytool.vdf"
sed -i "s#PROTON_BINARY_PATH#${proton_binary_path}#g" "${proton_compat_dir}/toolmanifest.vdf"