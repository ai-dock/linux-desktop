# For build automation - Allows building from any ai-dock base image
ARG IMAGE_BASE="ghcr.io/ai-dock/base-image:v2-cuda-12.1.1-cudnn8-runtime-22.04"
FROM ${IMAGE_BASE}

LABEL org.opencontainers.image.source https://github.com/ai-dock/linux-desktop
LABEL org.opencontainers.image.description "Docker desktop environment with hardware acceleration for NVIDIA, AMD and Intel GPUs"
LABEL maintainer="Rob Ballantyne <rob@dynamedia.uk>"

ENV SELKIES_VENV=$VENV_DIR/selkies
ENV SELKIES_VENV_PYTHON=$SELKIES_VENV/bin/python
ENV SELKIES_VENV_PIP=$SELKIES_VENV/bin/pip

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV USER_GROUPS=${USER_GROUPS},input,lpadmin
ENV DISPLAY :0
ENV VNC_DISPLAY :1
ENV XDG_RUNTIME_DIR /tmp/runtime-user

ENV PIPEWIRE_LATENCY="32/48000"
# https://forum.manjaro.org/t/howto-troubleshoot-crackling-in-pipewire/82442
ENV PULSE_LATENCY_MSEC=60
ENV DISABLE_RTKIT="y"

ENV VGL_DISPLAY=egl

ARG KASMVNC_VERSION=1.3.1
ENV KASMVNC_VERSION=${KASMVNC_VERSION}

ENV PATH /usr/local/nvidia/bin:/opt/VirtualGL/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}:/usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV SDL_JOYSTICK_DEVICE /dev/input/js0

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all
ENV __GL_SYNC_TO_VBLANK 0

ENV TZ UTC
ENV DISPLAY_SIZEW 1920
ENV DISPLAY_SIZEH 1080
ENV DISPLAY_REFRESH 60
ENV DISPLAY_DPI 96
ENV DISPLAY_CDEPTH 24

ARG SELKIES_VERSION=1.6.1
ENV SELKIES_VERSION=${SELKIES_VERSION}
ENV SELKIES_ENCODER nvh264enc
ENV SELKIES_ENABLE_RESIZE false
ENV SELKIES_ENABLE_BASIC_AUTH false

ENV XDG_CURRENT_DESKTOP KDE
ENV XDG_SESSION_DESKTOP KDE
ENV XDG_SESSION_TYPE x11
ENV DESKTOP_SESSION plasma
ENV KDE_FULL_SESSION true
ENV KDE_APPLICATIONS_AS_SCOPE=1
ENV KWIN_COMPOSE N
ENV KWIN_X11_NO_SYNC_TO_VBLANK 1
ENV SUDO_EDITOR kate
# Set input to fcitx
ENV GTK_IM_MODULE fcitx
ENV QT_IM_MODULE fcitx
ENV XIM fcitx
ENV XMODIFIERS "@im=fcitx"

ENV APPIMAGE_EXTRACT_AND_RUN 1

ARG WINE_BRANCH=staging
ENV WINE_BRANCH=${WINE_BRANCH}

# Copy early so we can use scripts in the build - Changes to these files will invalidate the cache and cause a rebuild.
COPY --chown=0:1111 ./COPY_ROOT_0/ /

ENV OPT_SYNC=$OPT_SYNC
ENV IMAGE_SLUG="linux-desktop"

# Use build scripts to ensure we can build all targets from one Dockerfile in a single layer.
# Don't put anything heavy in here - We can use multi-stage building above if necessary.

RUN set -eo pipefail && /opt/ai-dock/bin/build/layer0/init.sh | tee /var/log/build.log

# Copy overrides and new files into a final layer for fast rebuilds. Uncomment below
COPY --chown=0:1111 ./COPY_ROOT_99/ /
RUN set -eo pipefail && /opt/ai-dock/bin/build/layer99/init.sh | tee -a /var/log/build.log

# Keep init.sh as-is and place additional logic in /opt/ai-dock/bin/preflight.sh
CMD ["init.sh"]
