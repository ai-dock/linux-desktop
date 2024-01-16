# For build automation - Allows building from any ai-dock base image
ARG IMAGE_BASE="ghcr.io/ai-dock/base-image:cuda-11.8.0-base-22.04"
FROM ${IMAGE_BASE}

LABEL org.opencontainers.image.source https://github.com/ai-dock/desktop
LABEL org.opencontainers.image.description "Docker desktop environment"
LABEL maintainer="Rob Ballantyne <rob@dynamedia.uk>"

ENV USER_GROUPS=$USER_GROUPS,pulse-access

ENV DISPLAY :0
ENV XDG_RUNTIME_DIR /tmp/runtime-user
ENV PULSE_SERVER unix:/run/pulse/native

# Expose NVIDIA libraries and paths
ENV PATH /usr/local/nvidia/bin:/opt/VirtualGL/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu:/usr/local/nvidia/lib:/usr/local/nvidia/lib64
# Make all NVIDIA GPUs visible by default
ENV NVIDIA_VISIBLE_DEVICES all
# All NVIDIA driver capabilities should preferably be used, check `NVIDIA_DRIVER_CAPABILITIES` inside the container if things do not work
ENV NVIDIA_DRIVER_CAPABILITIES all
# Disable VSYNC for NVIDIA GPUs
ENV __GL_SYNC_TO_VBLANK 0

# Default environment variables (password is "mypasswd")

ENV SIZEW 1920
ENV SIZEH 1080
ENV REFRESH 60
ENV DPI 96
ENV CDEPTH 24

ENV VGL_DISPLAY egl
ENV VIDEO_PORT=DFB

ENV WEBRTC_ENCODER x264enc
ENV WEBRTC_ENABLE_RESIZE false

# Set versions for components that should be manually checked before upgrading, other component versions are automatically determined by fetching the version online
ARG VIRTUALGL_VERSION=3.1
ENV VIRTUALGL_VERSION=${VIRTUALGL_VERSION}

# Install KDE and other GUI packages
ENV XDG_CURRENT_DESKTOP KDE
ENV XDG_SESSION_DESKTOP KDE
ENV XDG_SESSION_TYPE x11
ENV DESKTOP_SESSION plasma
ENV KDE_FULL_SESSION true
ENV KWIN_COMPOSE N
ENV KWIN_X11_NO_SYNC_TO_VBLANK 1
# Use sudoedit to change protected files instead of using sudo on kate
ENV SUDO_EDITOR kate

# Enable AppImage execution in containers
ENV APPIMAGE_EXTRACT_AND_RUN 1

# Add new paths at front 
#ENV PATH=/opt/another/bin:$PATH

# Copy early so we can use scripts in the build - Changes to these files will invalidate the cache and cause a rebuild.
COPY ./COPY_ROOT/ /

# Define the startup mamba environment for interactive sessions.
# ENV for inheritance

ENV OPT_SYNC=$OPT_SYNC
ENV IMAGE_SLUG="desktop"
# Use build scripts to ensure we can build all targets from one Dockerfile in a single layer.
# Don't put anything heavy in here - We can use multi-stage building above if necessary.

RUN set -eo pipefail && /opt/ai-dock/bin/build/layer0/init.sh | tee /var/log/build.log
ENV LD_PRELOAD /usr/local/lib/selkies-js-interposer/joystick_interposer.so${LD_PRELOAD:+:${LD_PRELOAD}}
ENV SDL_JOYSTICK_DEVICE /dev/input/js0

# Copy overrides and new files into a final layer for fast rebuilds. Uncomment below
COPY ./COPY_ROOT_EXTRA/ /
RUN set -eo pipefail && /opt/ai-dock/bin/build/layer1/init.sh | tee -a /var/log/build.log

# Keep init.sh as-is and place additional logic in /opt/ai-dock/bin/preflight.sh
CMD ["init.sh"]
