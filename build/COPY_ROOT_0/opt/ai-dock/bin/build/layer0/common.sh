#!/bin/false

source /opt/ai-dock/etc/environment.sh

build_common_main() {
    add-apt-repository multiverse
    apt-get update
    build_common_install_xorg
    build_common_install_pipewire
    build_common_install_virtualgl
    build_common_install_kde
    build_common_install_packages
    build_common_install_selkies
    build_common_install_kasmvnc
    build_common_install_coturn
}


function build_common_install_xorg() {
    # Minimal xorg installation
    $APT_INSTALL \
        alsa-base \
        alsa-utils \
        clinfo \
        cups-browsed \
        cups-bsd \
        cups-common \
        cups-filters \
        cups-pdf \
        dbus-user-session \
        dbus-x11 \
        fonts-dejavu \
        fonts-freefont-ttf \
        fonts-hack \
        fonts-liberation \
        fonts-noto \
        fonts-noto-cjk \
        fonts-noto-cjk-extra \
        fonts-noto-color-emoji \
        fonts-noto-extra \
        fonts-noto-hinted \
        fonts-noto-mono \
        fonts-noto-unhinted \
        fonts-opensymbol \
        fonts-symbola \
        fonts-ubuntu \
        gstreamer1.0-plugins-bad \
        libgstreamer-plugins-bad1.0-dev \
        im-config \
        lame \
        libavcodec-extra \
        libdatetime-perl \
        libdbus-c++-1-0v5 \
        libegl1 \
        libegl-dev \
        libegl1:i386 \
        libelf-dev \
        libgles2 \
        libgles2:i386 \
        libgl1 \
        libgl1:i386 \
        libglu1 \
        libglu1:i386 \
        libglvnd0 \
        libglvnd0:i386 \
        libopenjp2-7 \
        libopus0 \
        libpulse0 \
        libsm6 \
        libsm6:i386 \
        libva2 \
        libva2:i386 \
        libva-dev \
        libvulkan-dev \
        libvulkan-dev:i386 \
        libxcb1 \
        libxcb1:i386 \
        libxau6 \
        libxau6:i386 \
        libx11-6 \
        libx11-6:i386 \
        libxext6 \
        libxext6:i386 \
        libxkbcommon0 \
        libxrandr-dev \
        libxdmcp6 \
        libxdmcp6:i386 \
        libxv1 \
        libxv1:i386 \
        libxvmc1 \
        libxtst6 \
        libxtst6:i386 \
        libzita-alsa-pcmi0 \
        libzita-resampler1 \
        mesa-utils \
        mesa-utils-extra \
        mesa-vulkan-drivers \
        mesa-vulkan-drivers:i386 \
        meson \
        net-tools \
        ocl-icd-libopencl1 \
        packagekit-tools \
        python3 \
        python3-cups \
        ubuntu-drivers-common \
        vainfo \
        va-driver-all \
        va-driver-all:i386 \
        vdpau-driver-all \
        vdpau-driver-all:i386 \
        vdpauinfo \
        vulkan-tools \
        whoopsie \
        wmctrl \
        x11-apps \
        x11-utils \
        x11-xkb-utils \
        x11-xserver-utils \
        x264 \
        x265 \
        xauth \
        xbitmaps \
        xclip \
        xcvt \
        cups-bsd \
        xdg-user-dirs \
        xdg-utils \
        xfonts-base \
        xfonts-scalable \
        xinit \
        xkb-data \
        xsel \
        xsettingsd \
        xserver-xorg-input-all \
        xserver-xorg-input-wacom \
        xserver-xorg-video-all \
        xserver-xorg-video-qxl \
        xorg \
        xvfb
}

function build_common_install_pipewire() { 
    curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xFC43B7352BCC0EC8AF2EEB8B25088A0359807596" \
        | gpg --dearmor -o /etc/apt/trusted.gpg.d/pipewire-debian-ubuntu-pipewire-upstream.gpg
    codename=$(grep UBUNTU_CODENAME= /etc/os-release | cut -d= -f2 | tr -d '\"')
    echo "deb https://ppa.launchpadcontent.net/pipewire-debian/pipewire-upstream/ubuntu ${codename} main" \
        > "/etc/apt/sources.list.d/pipewire-debian-ubuntu-pipewire-upstream-${codename}.list"
    echo "deb https://ppa.launchpadcontent.net/pipewire-debian/wireplumber-upstream/ubuntu ${codename} main" \
        > "/etc/apt/sources.list.d/pipewire-debian-ubuntu-wireplumber-upstream-${codename}.list"

    apt-get update
    $APT_INSTALL \
        pipewire \
        pipewire-alsa \
        pipewire-audio-client-libraries \
        pipewire-jack \
        pipewire-locales \
        pipewire-v4l2 \
        pipewire-libcamera \
        gstreamer1.0-pipewire \
        libpipewire-0.3-modules \
        libpipewire-module-x11-bell \
        libspa-0.2-jack \
        libspa-0.2-modules \
        wireplumber \
        wireplumber-locales \
        gir1.2-wp-0.4
}

function build_common_install_virtualgl() {
    export VIRTUALGL_VERSION="$(curl -fsSL "https://api.github.com/repos/VirtualGL/virtualgl/releases/latest" | jq -r '.tag_name' | sed 's/[^0-9\.\-]*//g')"
    env-store VIRTUALGL_VERSION
    cd /tmp
    wget "https://github.com/VirtualGL/virtualgl/releases/download/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb"
    wget "https://github.com/VirtualGL/virtualgl/releases/download/${VIRTUALGL_VERSION}/virtualgl32_${VIRTUALGL_VERSION}_amd64.deb"
    
    $APT_INSTALL \
        /tmp/virtualgl_${VIRTUALGL_VERSION}_amd64.deb \
        /tmp/virtualgl32_${VIRTUALGL_VERSION}_amd64.deb
    
    chmod u+s /usr/lib/libvglfaker.so
    chmod u+s /usr/lib/libvglfaker-nodl.so
    chmod u+s /usr/lib/libvglfaker-opencl.so 
    chmod u+s /usr/lib/libdlfaker.so 
    chmod u+s /usr/lib/libgefaker.so

    chmod u+s /usr/lib32/libvglfaker.so
    chmod u+s /usr/lib32/libvglfaker-nodl.so
    chmod u+s /usr/lib32/libvglfaker-opencl.so
    chmod u+s /usr/lib32/libdlfaker.so
    chmod u+s /usr/lib32/libgefaker.so

    chmod u+s /usr/lib/i386-linux-gnu/libvglfaker.so
    chmod u+s /usr/lib/i386-linux-gnu/libvglfaker-nodl.so
    chmod u+s /usr/lib/i386-linux-gnu/libvglfaker-opencl.so
    chmod u+s /usr/lib/i386-linux-gnu/libdlfaker.so
    chmod u+s /usr/lib/i386-linux-gnu/libgefaker.so
}

function build_common_install_kasmvnc() {
    cd /tmp
    YQ_VERSION="$(curl -fsSL "https://api.github.com/repos/mikefarah/yq/releases/latest" \
        | jq -r '.tag_name' \
        | sed 's/[^0-9\.\-]*//g')"
    curl -o yq -fsSL "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_$(dpkg --print-architecture)"
    install ./yq /usr/local/bin/
   
    wget https://github.com/kasmtech/KasmVNC/releases/download/v${KASMVNC_VERSION}/kasmvncserver_jammy_${KASMVNC_VERSION}_amd64.deb
    $APT_INSTALL \
        /tmp/kasmvncserver_jammy_${KASMVNC_VERSION}_amd64.deb
}

function build_common_install_kde() {
    # Essentials for KDE to start without issues
    $APT_INSTALL \
        kde-plasma-desktop \
        adwaita-icon-theme-full \
        appmenu-gtk3-module \
        ark \
        aspell \
        aspell-en \
        breeze \
        breeze-cursor-theme \
        breeze-gtk-theme \
        breeze-icon-theme \
        debconf-kde-helper \
        desktop-file-utils \
        dolphin \
        dolphin-plugins \
        dbus-x11 \
        enchant-2 \
        fcitx \
        fcitx-frontend-gtk2 \
        fcitx-frontend-gtk3 \
        fcitx-frontend-qt5 \
        fcitx-module-dbus \
        fcitx-module-kimpanel \
        fcitx-module-lua \
        fcitx-module-x11 \
        fcitx-tools \
        fcitx-hangul \
        fcitx-libpinyin \
        fcitx-m17n \
        fcitx-mozc \
        fcitx-sayura \
        fcitx-unikey \
        filelight \
        frameworkintegration \
        gwenview \
        haveged \
        hunspell \
        im-config \
        kate \
        kcalc \
        kcharselect \
        kdeadmin \
        kde-config-fcitx \
        kde-config-gtk-style \
        kde-config-gtk-style-preview \
        kdeconnect \
        kdegraphics-thumbnailers \
        kde-spectacle \
        kdf \
        kdialog \
        kget \
        kimageformat-plugins \
        kinfocenter \
        kio \
        kio-extras \
        kmag \
        kmenuedit \
        kmix \
        kmousetool \
        kmouth \
        ksshaskpass \
        ktimer \
        kwayland-integration \
        kwin-addons \
        kwin-x11 \
        libdbusmenu-glib4 \
        libdbusmenu-gtk3-4 \
        libgail-common \
        libgdk-pixbuf2.0-bin \
        libgtk2.0-bin \
        libgtk-3-bin \
        libkf5baloowidgets-bin \
        libkf5dbusaddons-bin \
        libkf5iconthemes-bin \
        libkf5kdelibs4support5-bin \
        libkf5khtml-bin \
        libkf5parts-plugins \
        libqt5multimedia5-plugins \
        librsvg2-common \
        media-player-info \
        okular \
        okular-extra-backends \
        partitionmanager \
        plasma-browser-integration \
        plasma-calendar-addons \
        plasma-dataengines-addons \
        plasma-discover \
        plasma-integration \
        plasma-runners-addons \
        plasma-widgets-addons \
        policykit-desktop-privileges \
        polkit-kde-agent-1 \
        print-manager \
        qapt-deb-installer \
        qml-module-org-kde-runnermodel \
        qml-module-org-kde-qqc2desktopstyle \
        qml-module-qtgraphicaleffects \
        qml-module-qtquick-xmllistmodel \
        qt5-gtk-platformtheme \
        qt5-image-formats-plugins \
        qt5-style-plugins \
        qtspeech5-flite-plugin \
        qtvirtualkeyboard-plugin \
        software-properties-qt \
        sonnet-plugins \
        sweeper \
        systemsettings \
        ubuntu-drivers-common \
        xdg-desktop-portal-kde \
        xdg-user-dirs \
        pavucontrol-qt
    
    # Fix KDE startup permissions issues in containers
    #cp -f /usr/lib/x86_64-linux-gnu/libexec/kf5/start_kdeinit /tmp/
    #rm -f /usr/lib/x86_64-linux-gnu/libexec/kf5/start_kdeinit
    #cp -r /tmp/start_kdeinit /usr/lib/x86_64-linux-gnu/libexec/kf5/start_kdeinit
    #rm -f /tmp/start_kdeinit
}

function build_common_install_packages() {
    mkdir -pm755 /etc/apt/trusted.gpg.d && curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x0AB215679C571D1C8325275B9BDB3D89CE49EC21" | gpg --dearmor -o /etc/apt/trusted.gpg.d/mozillateam-ubuntu-ppa.gpg && \
    mkdir -pm755 /etc/apt/sources.list.d && echo "deb https://ppa.launchpadcontent.net/mozillateam/ppa/ubuntu $(grep UBUNTU_CODENAME= /etc/os-release | cut -d= -f2 | tr -d '\"') main" > "/etc/apt/sources.list.d/mozillateam-ubuntu-ppa-$(grep UBUNTU_CODENAME= /etc/os-release | cut -d= -f2 | tr -d '\"').list" && \
    apt-get update

    $APT_INSTALL \
        firefox \
        vlc \
        vlc-l10n \
        vlc-plugin-access-extra \
        vlc-plugin-notify \
        vlc-plugin-samba \
        vlc-plugin-skins2 \
        vlc-plugin-video-splitter \
        vlc-plugin-visualization

        update-alternatives --set x-www-browser /usr/bin/firefox
}

function build_common_install_selkies() {
    # Install latest Selkies-GStreamer (https://github.com/selkies-project/selkies-gstreamer) build, Python application, and web application, should be consistent with selkies-gstreamer documentation
    
    # Many duplicates here, but easiest to track selkies package list directly
    $APT_INSTALL \
        python3-pip \
        python3-dev \
        python3-gi \
        python3-setuptools \
        python3-wheel \
        libaa1 \
        bzip2 \
        libgcrypt20 \
        libcairo-gobject2 \
        libpangocairo-1.0-0 \
        libgdk-pixbuf2.0-0 \
        libsoup2.4-1 \
        libsoup-gnome2.4-1 \
        libgirepository-1.0-1 \
        glib-networking \
        libglib2.0-0 \
        libjson-glib-1.0-0 \
        libgudev-1.0-0 \
        alsa-utils \
        jackd2 \
        libjack-jackd2-0 \
        libpulse0 \
        libogg0 \
        libopus0 \
        libvorbis-dev \
        libjpeg-turbo8 \
        libopenjp2-7 \
        libvpx-dev \
        libwebp-dev \
        x264 \
        x265 \
        libdrm2 \
        libegl1 \
        libgl1 \
        libopengl0 \
        libgles1 \
        libgles2 \
        libglvnd0 \
        libglx0 \
        wayland-protocols \
        libwayland-dev \
        libwayland-egl1 \
        wmctrl \
        xsel \
        xdotool \
        x11-utils \
        x11-xserver-utils \
        xserver-xorg-core \
        libx11-xcb1 \
        libxcb-dri3-0 \
        libxkbcommon0 \
        libxdamage1 \
        libxfixes3 \
        libxv1 \
        libxtst6 \
        libxext6

    # > Ubuntu 20.04
    $APT_INSTALL \
        xcvt libopenh264-dev libde265-0 svt-av1 aom-tools

    if [[ -z $SELKIES_VERSION || ${SELKIES_VERSION,,} == 'latest' ]]; then
        export SELKIES_VERSION="$(curl -fsSL "https://api.github.com/repos/selkies-project/selkies-gstreamer/releases/latest" \
            | jq -r '.tag_name' | sed 's/[^0-9\.\-]*//g')"
        env-store SELKIES_VERSION
    fi
    
    $APT_INSTALL \
        python3-venv

    python3 -m venv --system-site-packages "$SELKIES_VENV"

    cd /opt 
    curl -fsSL "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/gstreamer-selkies_gpl_v${SELKIES_VERSION}_ubuntu$(grep VERSION_ID= /etc/os-release | cut -d= -f2 | tr -d '\"')_$(dpkg --print-architecture).tar.gz" \
        | tar -xzf -
    curl -fsSL "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies-gstreamer-web_v${SELKIES_VERSION}.tar.gz" \
        | tar -xzf -

    cd /tmp 
    curl -O -fsSL "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies_gstreamer-${SELKIES_VERSION}-py3-none-any.whl" 
    "$SELKIES_VENV_PIP" install --no-cache-dir --force-reinstall "selkies_gstreamer-${SELKIES_VERSION}-py3-none-any.whl"

    curl -o selkies-js-interposer.deb -fsSL "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies-js-interposer_v${SELKIES_VERSION}_ubuntu$(grep VERSION_ID= /etc/os-release | cut -d= -f2 | tr -d '\"')_$(dpkg --print-architecture).deb"
    $APT_INSTALL ./selkies-js-interposer.deb
}

function build_common_install_coturn() {
    $APT_INSTALL coturn
}

build_common_main "$@"