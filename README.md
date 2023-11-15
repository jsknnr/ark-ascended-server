# ark-ascended-server
[![Push New Version](https://github.com/jsknnr/ark-ascended-server/actions/workflows/docker-publish.yaml/badge.svg)](https://github.com/jsknnr/ark-ascended-server/actions/workflows/docker-publish.yaml)<br>

Containerized Ark: Survival Ascended server

This project runs the Windows Ark: SA binaries in Debian 12 Linux headless with GE Proton.

[Docker Hub](https://hub.docker.com/r/sknnr/ark-ascended-server)

**Disclaimer:** This is not an official image. No support, implied or otherwise is offered to any end user by the author or anyone else. Feel free to do what you please with the contents of this repo. Do good.

## Usage

The processes within the container do **NOT** run as root. Everything runs as the user steam (gid:1000/uid:1000). There is no interface at all, everything runs headless. If you exec into the container, you will drop into `/home/steam` as the steam user. Ark: SA will be installed to `/home/steam/ark`. Any persistent volumes should be mounted to `/home/steam/ark/ShooterGame/Saved`. Supervisor is used within the container to manage the server process and a secondary process to feed the server logs into stdout so they can easily be viewed. The container does include a text editor (vim) if you need to make changes to any config file. I've included a Helm chart and templates in this repo for easily running the server in a Kubernetes cluster (this is how I prefer to run my game servers). If you are not familiar with Helm or Kubernetes, that's ok, neither are required for running the container. I've also included a Makefile for quickly building and running a test instance of the container. This is intended for development and testing purposes and not for actually running the container to play. I think that about covers it.

### Ports

| Port | Protocol | Default |
| ---- | -------- | ------- |
| Game Port | UDP | 7777 |
| RCON Port | TCP | 27020 |

This is the port required by Ark: SA. If you have read elsewhere about the query port, that is deprecated and not used in the Survival Ascended version of Ark. If you are not able to see your server on the server list or you are unable to connect, simply put, you are doing something wrong. There is nothing wrong with the container when it comes ot this. There are too many models and configurations of routers out there for me to provide examples. Refer to the documentation on your router and do some research on how port forwarding works if you run into issues. 

If you are still running into issues, there is one potential cause that may be out of your control that I feel I must mention. Some ISPs (internet service providers) utilize a technology called CNAT/CGNAT (Carrier/Carrier Grade NAT). Briefly put, this allows your ISP to use a singular public IP address for many customers. Due to the sharing of a single public IP address, this can interfere or prevent you from port forwarding from your public IP address. If you believe this is the case for you, you should contact your ISP and ask if they are doing this. You may be able to request a static public IP address, though your ISP will likely charge extra for this.

### Environment Variables

| Name | Description | Default | Required |
| ---- | ----------- | ------- |
| SERVER_MAP | The map that the server runs | TheIsland_WP | True |
| SESSION_NAME | The name for you server/session | None | True |
| SERVER_PASSWORD | The password to join your server | None | True |
| SERVER_ADMIN_PASSWORD | The password for utilizing admin functions | None | True |
| GAME_PORT | This is the port that the server accepts incoming traffic on | 7777 | True |
| RCON_PORT | The port for the RCON service to listen on | 27020 | False |
| MODS | Comma separated list of CurseForge project IDs. Example: ModId1,ModId2,etc | None | False |
| EXTRA_FLAGS | Space separated list of additional server start flags. Example: -NoBattlEye -ForceAllowCaveFlyers | None | False |
| EXTRA_SETTINGS | ? Separated list of additional server settings. Example: ?serverPVE=True?ServerHardcore=True | None | False |

### Docker

To run the container in Docker, run the following command:

```bash
mkdir ark-persistent-data
docker run \
  --detach \
  --name Ark-Ascended-Server \
  --mount type=bind,source=$(pwd)/ark-persistent-data,target=/home/steam/ark/ShooterGame/Saved \
  --publish 7777:7777/udp \
  --env=SERVER_MAP=TheIsland_WP \
  --env=SESSION_NAME="My Ark Ascended Server" \
  --env=SERVER_PASSWORD="ChangeThisPlease" \
  --env=SERVER_ADMIN_PASSWORD="AlsoChangeThis" \
  --env=GAME_PORT=7777 \
  sknnr/ark-ascended-server:latest
```

If you are missing a required variable that does not have a default listed the container will error and exit.

To include non-required arguments just add a new `--env=` line to the above script.
To use RCON you must both publish the port and add the environment variable.
It should go without saying but, the environment variables for RCON (if you are using RCON) and Game Port should match the published ports.

The first line of the above creates a new directory called `ark-persistent-data` in the directory you are currently in. This is the directory that will be mounted into the container that will contain your server config files and the save world. If you delete the container, this directory will persist, keeping your config files and save data. If you delete this folder, you will lose your world save.

Depending on the performance of the computer/server where you are running the container, it may take a few minutes for the server to fully start and appear on the server list. Be sure to select unofficial servers from the list and tick the box that shows password protected servers.

If you need to update the ARK: SA server binaries, you can simply stop and then start the container (or re-create it) as the binaries are checked for updates each time the container starts. For example:

```bash
docker stop Ark-Ascended-Server && docker start Ark-Ascended-Server
```

Concerning Backups: The container does not currently nor do I plan to have it manage backups. Since the backup within the container would still be on the same persistent volume it seems silly without further integration to transfer the backup out of the container and to a 3rd party target such as AWS S3... which I could build integration for but I doubt most users are using AWS and if you are I am sure you could build the functionality your self. For now I recommend backing up the volume that gets mounted into the container in whichever manner you see fit.

### Kubernetes

I've built a Helm chart and templates and have included them in the `helm` directory within this repo. Modify the `values.yaml` file to your liking and install the chart into your cluster. Be sure to create and specify a namespace as I did not include a template for provisioning a namespace.
