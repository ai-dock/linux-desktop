[![Docker Build](https://github.com/ai-dock/linux-desktop/actions/workflows/docker-build.yml/badge.svg)](https://github.com/ai-dock/linux-desktop/actions/workflows/docker-build.yml)

# Linux Desktop

Run a hardware accelerated KDE desktop in a container. This image is heavily influenced by [Selkies Project](https://github.com/selkies-project) to provide an accelerated desktop environment for NVIDIA, AMD and Intel machines.  

Please see this [important notice](#selkies-notice) from the Selkies development team.


## Documentation

All AI-Dock containers share a common base which is designed to make running on cloud services such as [vast.ai](https://link.ai-dock.org/vast.ai) as straightforward and user friendly as possible.

Common features and options are documented in the [base wiki](https://github.com/ai-dock/base-image/wiki) but any additional features unique to this image will be detailed below.


#### Version Tags

The `:latest` tag points to `:latest-cuda`

Tags follow these patterns:

##### _CUDA_
- `:cuda-[x.x.x]{-cudnn[x]}-[base|runtime|devel]-[ubuntu-version]`

- `:latest-cuda` &rarr; `:cuda-12.1.1-cudnn8-runtime-22.04`

##### _ROCm_
- `:rocm-[x.x.x]-[core|runtime|devel]-[ubuntu-version]`

- `:latest-rocm` &rarr; `:rocm-6.0-runtime-22.04`

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

## Selkies Notice

This project has been developed and is supported in part by the National Research Platform (NRP) and the Cognitive Hardware and Software Ecosystem Community Infrastructure (CHASE-CI) at the University of California, San Diego, by funding from the National Science Foundation (NSF), with awards #1730158, #1540112, #1541349, #1826967, #2138811, #2112167, #2100237, and #2120019, as well as additional funding from community partners, infrastructure utilization from the Open Science Grid Consortium, supported by the National Science Foundation (NSF) awards #1836650 and #2030508, and infrastructure utilization from the Chameleon testbed, supported by the National Science Foundation (NSF) awards #1419152, #1743354, and #2027170. This project has also been funded by the Seok-San Yonsei Medical Scientist Training Program (MSTP) Song Yong-Sang Scholarship, College of Medicine, Yonsei University, the MD-PhD/Medical Scientist Training Program (MSTP) through the Korea Health Industry Development Institute (KHIDI), funded by the Ministry of Health & Welfare, Republic of Korea, and the Student Research Bursary of Song-dang Institute for Cancer Research, College of Medicine, Yonsei University.

---

_The author ([@robballantyne](https://github.com/robballantyne)) may be compensated if you sign up to services linked in this document. Testing multiple variants of GPU images in many different environments is both costly and time-consuming; This helps to offset costs_