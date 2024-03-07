# For build automation - Allows building from any ai-dock base image
ARG IMAGE_BASE="ghcr.io/ai-dock/base-image:cuda-11.8.0-base-22.04"
FROM ${IMAGE_BASE}

LABEL org.opencontainers.image.source https://github.com/ai-dock/linux-desktop
LABEL org.opencontainers.image.description "Docker desktop environment"
LABEL maintainer="Rob Ballantyne <rob@dynamedia.uk>"

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV USER_GROUPS=${USER_GROUPS},input,lpadmin,pulse-access
ENV DISPLAY :0
ENV VNC_DISPLAY :1
ENV XDG_RUNTIME_DIR /tmp/runtime-user
ENV PULSE_SERVER unix:/run/pulse/native

ENV VGL_DISPLAY egl
ARG VIRTUALGL_VERSION=3.1
ENV VIRTUALGL_VERSION=${VIRTUALGL_VERSION}

ARG KASMVNC_VERSION=1.2.0
ENV KASMVNC_VERSION=${KASMVNC_VERSION}

ENV PATH /usr/local/nvidia/bin:/opt/VirtualGL/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}:/usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV SDL_JOYSTICK_DEVICE /dev/input/js0

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all
ENV __GL_SYNC_TO_VBLANK 0

# Default environment variables (password is "mypasswd")
ENV TZ UTC
ENV SIZEW 1920
ENV SIZEH 1080
ENV REFRESH 60
ENV DPI 96
ENV CDEPTH 24
# Hardcoded in x-server init. Users are breaking host machines. Do not use the on vast/runpod!!
#ENV VIDEO_PORT DFP

ENV WEBRTC_ENCODER nvh264enc
ENV WEBRTC_ENABLE_RESIZE false

ENV XDG_CURRENT_DESKTOP KDE
ENV XDG_SESSION_DESKTOP KDE
ENV XDG_SESSION_TYPE x11
ENV DESKTOP_SESSION plasma
ENV KDE_FULL_SESSION true
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

ARG STEAM_ARCHIVE_ID=20240216110829
ENV STEAM_ARCHIVE_ID=${STEAM_ARCHIVE_ID}
# Copy early so we can use scripts in the build - Changes to these files will invalidate the cache and cause a rebuild.
COPY --chown=0:1111 ./COPY_ROOT/ /

ENV OPT_SYNC=$OPT_SYNC
ENV IMAGE_SLUG="linux-desktop"

# Use build scripts to ensure we can build all targets from one Dockerfile in a single layer.
# Don't put anything heavy in here - We can use multi-stage building above if necessary.

RUN set -eo pipefail && /opt/ai-dock/bin/build/layer0/init.sh | tee /var/log/build.log

# Copy overrides and new files into a final layer for fast rebuilds. Uncomment below
COPY --chown=0:1111 ./COPY_ROOT_EXTRA/ /
RUN set -eo pipefail && /opt/ai-dock/bin/build/layer1/init.sh | tee -a /var/log/build.log

# Keep init.sh as-is and place additional logic in /opt/ai-dock/bin/preflight.sh
CMD ["init.sh"]
