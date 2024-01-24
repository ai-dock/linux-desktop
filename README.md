[![Docker Build](https://github.com/ai-dock/linux-desktop/actions/workflows/docker-build.yml/badge.svg)](https://github.com/ai-dock/linux-desktop/actions/workflows/docker-build.yml)

# Linux Desktop

Run a hardware accelerated KDE desktop in a container. This image is heavily influenced by [Selkies Project](https://github.com/selkies-project) and combines their GLX and EGL containers to provide an accelerated desktop environment for NVIDIA, AMD and Intel machines.

>[!NOTE] 
>This container image was designed to work with [vast.ai](https://link.ai-dock.org/template-vast-linux-desktop) and [runpod.io](https://link.ai-dock.org/template-runpod-linux-desktop) but will also work locally or with other GPU cloud services, however support for other services is limited.

## About Desktop

You may connect to the container through the [Selkies-gstreamer](https://github.com/selkies-project/selkies-gstreamer) WebRTC interface (default port `6100`) or through the [KasmVNC](https://github.com/kasmtech/KasmVNC) client (default port `6200`)

A [turn server](https://github.com/coturn/coturn) is bundled with the image to ensure connectivity is possible in most circumstances.  You should always prefer the WebRTC interface and use the VNC client only if you are unable to establish a WebRTC connection.

When running with an NVIDIA GPU, the container will attempt to download the relevant graphics driver and start a GLX enabled Xorg session.  For all other systems an Xvfb instance will be launched for VirtualGL rendering.

In situations where the NVIDIA Xorg instance cannot be launched, the container will fall back to VirtualGL rendering if possible.  This may happen where the drivers are incapable of handling a headless display or if there is already a physical display attached to the GPU.

In the worst case scenario a desktop will still be launched but rendered with llvmpipe if there is no NVIDIA driver present or if `/dev/dri` or `/dev/kfd` are not available within the container.


## Pre-built Images

Docker images are built automatically through a GitHub Actions workflow and hosted at the GitHub Container Registry. 

An incremental build process is used to avoid needing a huge cache - The following images are used to provide functionality:

- [nvidia/cuda](https://github.com/NVIDIA/nvidia-docker) / [ubuntu](https://github.com/docker-library/docs/tree/master/ubuntu) &#8628;
- [ai-dock/base-image](https://github.com/ai-dock/base-image) &#8628;
- ai-dock/linux-desktop

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

## Building Images

You can self-build from source by editing `docker-compose.yaml` or `.env` and running `docker compose build`.

It is a good idea to leave the source tree alone and copy any edits you would like to make into `build/COPY_ROOT_EXTRA/...`. The structure within this directory will be overlayed on `/` at the end of the build process.

As this overlaying happens after the main build, it is easy to add extra files such as ML models and datasets to your images. You will also be able to rebuild quickly if your file overrides are made here.

Any directories and files that you add into `opt/storage` will be made available in the running container at `$WORKSPACE/storage`.  

This directory is monitored by `inotifywait`. Any items appearing in this directory will be automatically linked to the application directories as defined in `/opt/ai-dock/storage_monitor/etc/mappings.sh`.  This is particularly useful if you need to run several applications that each need to make use of the stored files.

## Run Locally

A 'feature-complete' `docker-compose.yaml` file is included for your convenience. All features of the image are included - Simply edit the environment variables in `.env`, save and then type `docker compose up`.

If you prefer to use the standard `docker run` syntax, the command to pass is `init.sh`.

## Run in the Cloud

This image should be compatible with any GPU cloud platform. You simply need to pass environment variables at runtime. 

>[!NOTE]  
>Please raise an issue on this repository if your provider cannot run the image.

__Container Cloud__

Container providers don't give you access to the docker host but are quick and easy to set up. They are often inexpensive when compared to a full VM or bare metal solution.

All images built for ai-dock are tested for compatibility with both [vast.ai](https://link.ai-dock.org/template-vast-linux-desktop) and [runpod.io](https://link.ai-dock.org/template-runpod-linux-desktop).

See a list of pre-configured templates [here](#pre-configured-templates)

>[!WARNING]  
>Container cloud providers may offer both 'community' and 'secure' versions of their cloud. If your usecase involves storing sensitive information (eg. API keys, auth tokens) then you should always choose the secure option.

__VM Cloud__

Running docker images on a virtual machine/bare metal server is much like running locally.

You'll need to:
- Configure your server
- Set up docker
- Clone this repository
- Edit `.env`and `docker-compose.yml`
- Run `docker compose up`

Find a list of compatible VM providers [here](#compatible-vm-providers).

### Connecting to Your Instance

All services listen for connections at [`0.0.0.0`](https://en.m.wikipedia.org/wiki/0.0.0.0). This gives you some flexibility in how you interact with your instance:

_**Expose the Ports**_

This is fine if you are working locally but can be **dangerous for remote connections** where data is passed in plaintext between your machine and the container over http.

_**SSH Tunnel**_

You will only need to expose port `22` (SSH) which can then be used with port forwarding to allow **secure** connections to your services.

If you are unfamiliar with port forwarding then you should read the guides [here](https://link.ai-dock.org/guide-ssh-tunnel-do-a) and [here](https://link.ai-dock.org/guide-ssh-tunnel-do-b).

_**Cloudflare Tunnel**_

You can use the included `cloudflared` service to make secure connections without having to expose any ports to the public internet. See more below.

## Environment Variables

| Variable                 | Description |
| ------------------------ | ----------- |
| `CF_TUNNEL_TOKEN`        | Cloudflare zero trust tunnel token - See [documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/). |
| `CF_QUICK_TUNNELS`       | Create ephemeral Cloudflare tunnels for web services (default `false`) |
| `COTURN_USER`            | Username for Coturn auth. Default `user` |
| `COTURN_PASSWORD`        | Password for Coturn auth. Auto-generated by default. |
| `COTURN_LISTEN_ADDRESS`  | Override the default listening address. Uses external IP by default. |
| `COTURN_PORT_HOST`       | Default is `3478`
| `DIRECT_ADDRESS`         | IP/hostname for service portal direct links (default `localhost`) |
| `DIRECT_ADDRESS_GET_WAN` | Use the internet facing interface for direct links (default `false`) |
| `ENABLE_COTURN`          | Enable the turn server, Default `false` |
| `GPU_COUNT`              | Limit the number of available GPUs |
| `PROVISIONING_SCRIPT`    | URL of a remote script to execute on init. See [note](#provisioning-script). |
| `RCLONE_*`               | Rclone configuration - See [rclone documentation](https://rclone.org/docs/#config-file) |
| `SSH_PORT_LOCAL`         | Set a non-standard port for SSH (default `22`) |
| `SSH_PUBKEY`             | Your public key for SSH |
| `TURN_HOST`              | Turn server address if not using builtin Coturn server |
| `TURN_PORT`              | Turn server address if not using builtin Coturn server |
| `TURN_USERNAME`          | Turn server username |
| `TURN_PASSWORD`          | Turn server password |
| `WEB_ENABLE_AUTH`        | Enable password protection for web services (default `true`) |
| `WEB_USER`               | Username for web services (default `user`) |
| `WEB_PASSWORD`           | Password for web services (default `password`) |
| `WEBRTC_ENABLE_RESIZE`   | Enable resize. Default `false` |
| `WEBRTC_ENCODER`         | Default `nvh264enc`. Available options: `vah264enc`, `x264enc`, `vp8enc`, `vp9enc` |
| `WORKSPACE`              | A volume path. Defaults to `/workspace/` |
| `WORKSPACE_SYNC`         | Move mamba environments and services to workspace if mounted (default `true`) |

Environment variables can be specified by using any of the standard methods (`docker-compose.yaml`, `docker run -e...`). Additionally, environment variables can also be passed as parameters of `init.sh`.

Passing environment variables to init.sh is usually unnecessary, but is useful for some cloud environments where the full `docker run` command cannot be specified.

Example usage: `docker run -e STANDARD_VAR1="this value" -e STANDARD_VAR2="that value" init.sh EXTRA_VAR="other value"`

## Security

By default, all exposed web services other than the port redirect page are protected by HTTP basic authentication.

The default username is `user` and the password is `password`.

You can set your credentials by passing environment variables as shown above.

The password is stored as a bcrypt hash. If you prefer not to pass a plain text password to the container you can pre-hash and use the variable `WEB_PASSWORD_HASH`.

If you are running the image locally on a trusted network, you may disable authentication by setting the environment variable `WEB_ENABLE_AUTH=false`.

The Coturn turn server username is `user` and a random password is generated on startup.  You can overide this behaviour by supplying `COTURN_USER` and `COTURN_PASSWORD` environment variables.

>[!NOTE]  
>You can use `set-web-credentials.sh <username> <password>` change the username and password in a running container.

## Provisioning script

It can be useful to perform certain actions when starting a container, such as creating directories and downloading files.

You can use the environment variable `PROVISIONING_SCRIPT` to specify the URL of a script you'd like to run.

The URL must point to a plain text file - GitHub Gists/Pastebin (raw) are suitable options.

If you are running locally you may instead opt to mount a script at `/opt/ai-dock/bin/provisioning.sh`.

>[!WARNING]  
>Only use scripts that you trust and which cannot be changed without your consent.

## Volumes

Data inside docker containers is ephemeral - You'll lose all of it when the container is destroyed.

You may opt to mount a data volume at `/workspace` - This is a directory that ai-dock images will look for to make downloaded data available outside of the container for persistence. 

This is usually of importance where large files are downloaded at runtime or if you need a space to save your work. This is the ideal location to store any code you are working on.

You can define an alternative path for the workspace directory by passing the environment variable `WORKSPACE=/my/alternative/path/` and mounting your volume there. This feature will generally assist where cloud providers enforce their own mountpoint location for persistent storage.

The provided docker-compose.yaml will mount the local directory `./workspace` at `/workspace`.

As docker containers generally run as the root user, new files created in /workspace will be owned by uid 0(root).

To ensure that the files remain accessible to the local user that owns the directory, the docker entrypoint will set a default ACL on the directory by executing the commamd `setfacl -d -m u:${WORKSPACE_UID}:rwx /workspace`.

If you do not want this, you can set the environment variable `SKIP_ACL=true`.

## Running Services

This image will spawn multiple processes upon starting a container because some of our remote environments do not support more than one container per instance.

All processes are managed by [supervisord](https://supervisord.readthedocs.io/en/latest/) and will restart upon failure until you either manually stop them or terminate the container.

>[!NOTE]  
>*Some of the included services would not normally be found **inside** of a container. They are, however, necessary here as some cloud providers give no access to the host; Containers are deployed as if they were a virtual machine.*

### Selkies-gstreamer

This provides the RTC interface for accessing the desktop through a web browser.

The service will bind to port `6100`.

See the [project page](https://github.com/selkies-project/selkies-gstreamer) for more information.

### Kasm VNC

This provides the VNC fallback interface for accessing the desktop through a web browser.

The service will bind to port `6200`.

See the [project page](https://kasmweb.com/kasmvnc) for more information.

### Kasm X Proxy

This service relays the desktop on display `:0` to the VNC on display `:1`

Learn about kasmxproxy [here](https://kasmweb.com/kasmvnc/docs/master/man/kasmxproxy.html).

### KDE Plasma

KDE plasma desktop environment.  Restarting this service will also restart the currently running X server.

### X Server

Either an Xorg server when running on NVIDIA hardware or Xvfb for VirtualGL rendering.

### Fcitx

Fcitx [ˈfaɪtɪks] is an input method framework with extension support.

See the [project page](https://fcitx-im.org/) for more information.

### Pulseaudio

Provides audio support for the WebRTC interface.  Audio is not supported over VNC.

### Caddy

This is a simple webserver acting as a reverse proxy.

Caddy is used to enable basic authentication for all sensitive web services.

To make changes to the caddy configuration inside a runing container you should edit `/opt/caddy/share/base_config` followed by `supervisorctl restart caddy`.

### Service Portal

This is a simple list of links to the web services available inside the container.

The service will bind to port `1111`.

For each service, you will find a direct link and, if you have set `CF_QUICK_TUNNELS=true`, a link to the service via a fast and secure Cloudflare tunnel.

A simple web-based log viewer and process manager are included for convenience.

### Cloudflared

The Cloudflare tunnel daemon will start if you have provided a token with the `CF_TUNNEL_TOKEN` environment variable.

This service allows you to connect to your local services via https without exposing any ports.

You can also create a private network to enable remote connecions to the container at its local address (`172.x.x.x`) if your local machine is running a Cloudflare WARP client.

If you do not wish to provide a tunnel token, you could enable `CF_QUICK_TUNNELS` which will create a throwaway tunnel for your web services.

Full documentation for Cloudflare tunnels is [here](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/).

>[!NOTE]  
>_Cloudflared is included so that secure networking is available in all cloud environments._

>[!WARNING]  
>You should only provide tunnel tokens in secure cloud environments.

### SSHD

A SSH server will be started if at least one valid public key is found inside the running container in the file `/root/.ssh/authorized_keys`

The server will bind to port `22` unless you specify variable `SSH_PORT`.

There are several ways to get your keys to the container.

- If using docker compose, you can paste your key in the local file `config/authorized_keys` before starting the container.
 
- You can pass the environment variable `SSH_PUBKEY` with your public key as the value.

- Cloud providers often have a built-in method to transfer your key into the container

If you choose not to provide a public key then the SSH server will not be started.

To make use of this service you should map port `22` to a port of your choice on the host operating system.

See [this guide](https://link.ai-dock.org/guide-sshd-do) by DigitalOcean for an excellent introduction to working with SSH servers.

>[!NOTE]  
>_SSHD is included because the end-user should be able to know the version prior to deloyment. Using a providers add-on, if available, does not guarantee this._

>[!WARNING]  
>You should only provide auth tokens in secure cloud environments.

### Logtail

This script follows and prints the log files for each of the above services to stdout. This allows you to follow the progress of all running services through docker's own logging system.

If you are logged into the container you can follow the logs by running `logtail.sh` in your shell.

### Storage Monitor

This service detects changes to files in `$WORKSPACE/storage` and creates symbolic links to the application directories defined in `/opt/ai-dock/storage_monitor/etc/mappings.sh`

## Open Ports

Some ports need to be exposed for the services to run or for certain features of the provided software to function


| Open Port             | Service / Description     |
| --------------------- | ------------------------- |
| `22`                  | SSH server                |
| `1111`                | Service portal web UI     |
| `3478`                | Coturn turn server        |
| `6100`                | Selkies WebRTC interface  |
| `6200`                | KASMVNC Interface         |

## Pre-Configured Templates

**Vast.​ai**

[linux-desktop:latest](https://link.ai-dock.org/template-vast-linux-desktop)

---

**Runpod.​io**

[linux-desktop:latest](https://link.ai-dock.org/template-runpod-linux-desktop)

---

>[!NOTE]  
>These templates are configured to use the `latest` tag but you are free to change to any of the available Linux-Desktop CUDA tags listed [here](https://github.com/ai-dock/python/pkgs/container/python)

## Compatible VM Providers

Images that do not require a GPU will run anywhere - Use an image tagged `:*-cpu-xx.xx`

Where a GPU is required you will need either `:*cuda*` or `:*rocm*` depending on the underlying hardware.

A curated list of VM providers currently offering GPU instances:

- [Akami/Linode](https://link.ai-dock.org/linode.com)
- [Amazon Web Services](https://link.ai-dock.org/aws.amazon.com)
- [Google Compute Engine](https://link.ai-dock.org/cloud.google.com)
- [Vultr](https://link.ai-dock.org/vultr.com)

---

_The author ([@robballantyne](https://github.com/robballantyne)) may be compensated if you sign up to services linked in this document. Testing multiple variants of GPU images in many different environments is both costly and time-consuming; This helps to offset costs_
