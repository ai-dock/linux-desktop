#!/bin/false

# For CPU specific processes. Includes Intel gfx for now
build_cpu_main() {
  $APT_INSTALL \
      i965-va-driver-shaders \
      i965-va-driver-shaders:i386 \
      intel-media-va-driver-non-free \
      intel-media-va-driver-non-free:i386 \
      xserver-xorg-video-intel
}

build_cpu_main "$@"