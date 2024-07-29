[![Docker Build](https://github.com/ai-dock/linux-desktop/actions/workflows/docker-build.yml/badge.svg)](https://github.com/ai-dock/linux-desktop/actions/workflows/docker-build.yml)

# Linux Desktop

Run a hardware accelerated KDE desktop in a container. This image is heavily influenced by [Selkies Project](https://github.com/selkies-project) to provide an accelerated desktop environment for NVIDIA, AMD and Intel machines.


## Documentation

All AI-Dock containers share a common base which is designed to make running on cloud services such as [vast.ai](https://link.ai-dock.org/vast.ai) as straightforward and user friendly as possible.

Common features and options are documented in the [base wiki](https://github.com/ai-dock/base-image/wiki) but any additional features unique to this image will be detailed below.


#### Version Tags

The `:latest` tag points to `:latest-cuda`

Tags follow these patterns:

##### _CUDA_
- `:cuda-[x.x.x]{-cudnn[x]}-[base|runtime|devel]-[ubuntu-version]`

- `:latest-cuda` &rarr; `:cuda-11.8.0-runtime-22.04`

##### _ROCm_
- `:rocm-[x.x.x]-[core|runtime|devel]-[ubuntu-version]`

- `:latest-rocm` &rarr; `:rocm-5.6-runtime-22.04`

ROCm builds are experimental. Please give feedback.

##### _CPU (iGPU)_
- `:cpu-[ubuntu-version]`

- `:latest-cpu` &rarr; `:cpu-22.04`

Browse [here](https://github.com/ai-dock/linux-desktop/pkgs/container/linux-desktop) for an image suitable for your target environment.

Supported Desktop Environments: `KDE Plasma`

Supported Platforms: `NVIDIA CUDA`, `AMD ROCm`, `CPU/iGPU`


## Pre-Configured Templates

**Vast.​ai**

[linux-desktop:latest](https://link.ai-dock.org/template-vast-linux-desktop)


---

_The author ([@robballantyne](https://github.com/robballantyne)) may be compensated if you sign up to services linked in this document. Testing multiple variants of GPU images in many different environments is both costly and time-consuming; This helps to offset costs_