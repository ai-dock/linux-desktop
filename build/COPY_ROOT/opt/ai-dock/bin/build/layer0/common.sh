#!/bin/false

source /opt/ai-dock/etc/environment.sh

build_common_main() {
    build_common_install_xorg
    build_common_install_virtualgl
    build_common_install_kde
    build_common_install_packages
    build_common_install_selkies
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
        im-config \
        lame \
        libavcodec-extra \
        libdbus-c++-1-0v5 \
        libegl1 \
        libegl1:i386 \
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
        libxtst6 \
        libxtst6:i386 \
        mesa-utils \
        mesa-utils-extra \
        mesa-vulkan-drivers \
        mesa-vulkan-drivers:i386 \
        net-tools \
        ocl-icd-libopencl1 \
        packagekit-tools \
        pulseaudio \
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
        xsettingsd \
        xserver-xorg-input-all \
        xserver-xorg-input-wacom \
        xserver-xorg-video-all \
        xserver-xorg-video-qxl \
        xvfb
}

function build_common_install_virtualgl() {
    cd /tmp
    curl -fsSL -O "https://github.com/VirtualGL/virtualgl/releases/download/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb"
    curl -fsSL -O "https://github.com/VirtualGL/virtualgl/releases/download/${VIRTUALGL_VERSION}/virtualgl32_${VIRTUALGL_VERSION}_amd64.deb"
    
    $APT_INSTALL \
        /tmp/virtualgl_${VIRTUALGL_VERSION}_amd64.deb \
        /tmp/virtualgl32_${VIRTUALGL_VERSION}_amd64.deb
    
    #chmod u+s /usr/lib/libvglfaker.so
    #chmod u+s /usr/lib/libdlfaker.so
    #chmod u+s /usr/lib32/libvglfaker.so
    #chmod u+s /usr/lib32/libdlfaker.so
    #chmod u+s /usr/lib/i386-linux-gnu/libvglfaker.so
    #chmod u+s /usr/lib/i386-linux-gnu/libdlfaker.so
}

function build_common_install_kde() {
    # Essentials for KDE to start without issues
    $APT_INSTALL \
        kde-plasma-desktop \
        frameworkintegration \
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
        systemsettings \
        xdg-desktop-portal-kde \
        xdg-user-dirs
}

function build_common_install_packages() {
    $APT_INSTALL \
        vlc
}

function build_common_install_selkies() {
    # Install latest Selkies-GStreamer (https://github.com/selkies-project/selkies-gstreamer) build, Python application, and web application, should be consistent with selkies-gstreamer documentation
    $APT_INSTALL \
        python3-pip \
        python3-dev \
        python3-gi \
        python3-setuptools \
        python3-wheel \
        libgl-dev \
        libgles-dev \
        libglvnd-dev \
        libgudev-1.0-0 \
        wayland-protocols \
        libwayland-dev \
        libsrtp2-1 \
        libwebrtc-audio-processing1 \
        libcairo-gobject2 \
        libpangocairo-1.0-0 \
        libgirepository-1.0-1 \
        libjpeg-dev \
        libwebp-dev \
        libvpx-dev \
        zlib1g-dev \
        i965-va-driver-shaders \
        intel-media-va-driver-non-free \
        intel-gpu-tools \
        radeontop
    
    if [[ -z $SELKIES_VERSION || ${SELKIES_VERSION,,} == 'latest' ]]; then
        SELKIES_VERSION="$(curl -fsSL "https://api.github.com/repos/selkies-project/selkies-gstreamer/releases/latest" \
            | jq -r '.tag_name' | sed 's/[^0-9\.\-]*//g')"
    fi
    
    cd /opt
    curl -fsSL "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies-gstreamer-v${SELKIES_VERSION}-ubuntu$(grep VERSION_ID= /etc/os-release | cut -d= -f2 | tr -d '\"').tgz" | tar -zxf -
    
    cd /tmp
    curl -fsSL -O "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies_gstreamer-${SELKIES_VERSION}-py3-none-any.whl"
    pip3 install "selkies_gstreamer-${SELKIES_VERSION}-py3-none-any.whl"
    
    cd /opt
    curl -fsSL "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies-gstreamer-web-v${SELKIES_VERSION}.tgz" | tar -zxf -
    
    cd /tmp
    curl -fsSL -o selkies-js-interposer.deb "https://github.com/selkies-project/selkies-gstreamer/releases/download/v${SELKIES_VERSION}/selkies-js-interposer-v${SELKIES_VERSION}-ubuntu$(grep VERSION_ID= /etc/os-release | cut -d= -f2 | tr -d '\"').deb"
    $APT_INSTALL ./selkies-js-interposer.deb
}

build_common_main "$@"