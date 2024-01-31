# ark-ascended-server
[![Static Badge](https://img.shields.io/badge/DockerHub-blue)](https://hub.docker.com/r/sknnr/ark-ascended-server) ![Docker Pulls](https://img.shields.io/docker/pulls/sknnr/ark-ascended-server) [![Static Badge](https://img.shields.io/badge/GitHub-green)](https://github.com/jsknnr/ark-ascended-server) ![GitHub Repo stars](https://img.shields.io/github/stars/jsknnr/ark-ascended-server)

Containerized Ark: Survival Ascended server

This project runs the Windows Ark: SA binaries in Debian 12 Linux headless with GE Proton.

**Disclaimer:** This is not an official image. No support, implied or otherwise is offered to any end user by the author or anyone else. Feel free to do what you please with the contents of this repo.

## Usage

The processes within the container do **NOT** run as root. Everything runs as the user steam (gid:10000/uid:10000). There is no interface at all, everything runs headless. If you exec into the container, you will drop into `/home/steam` as the steam user. Ark: SA will be installed to `/home/steam/ark`. Any persistent volumes should be mounted to `/home/steam/ark/ShooterGame/Saved`.

### Ports

| Port | Protocol | Default |
| ---- | -------- | ------- |
| Game Port | UDP | 7777 |
| RCON Port | TCP | 27020 |

This is the port required by Ark: SA. If you have read elsewhere about the query port, that is deprecated and not used in the Survival Ascended version of Ark. If you are not able to see your server on the server list or you are unable to connect, simply put, you are doing something wrong. There is nothing wrong with the container when it comes ot this. There are too many models and configurations of routers out there for me to provide examples. Refer to the documentation on your router and do some research on how port forwarding works if you run into issues. 

If you are still running into issues, there is one potential cause that may be out of your control that I feel I must mention. Some ISPs (internet service providers) utilize a technology called CNAT/CGNAT (Carrier/Carrier Grade NAT). Briefly put, this allows your ISP to use a singular public IP address for many customers. Due to the sharing of a single public IP address, this can interfere or prevent you from port forwarding from your public IP address. If you believe this is the case for you, you should contact your ISP and ask if they are doing this. You may be able to request a static public IP address, though your ISP will likely charge extra for this.

### Environment Variables

| Name | Description | Default | Required |
| ---- | ----------- | ------- | -------- |
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
docker volume create ark-persistent-data
docker run \
  --detach \
  --name Ark-Ascended-Server \
  --mount type=volume,source=ark-persistent-data,target=/home/steam/ark/ShooterGame/Saved \
  --publish 7777:7777/udp \
  --env=SERVER_MAP=TheIsland_WP \
  --env=SESSION_NAME="Ark Ascended Containerized" \
  --env=SERVER_PASSWORD="PleaseChangeMe" \
  --env=SERVER_ADMIN_PASSWORD="AlsoChangeMe" \
  --env=GAME_PORT=7777 \
  sknnr/ark-ascended-server:latest
```

### Docker Compose

To use Docker Compose, either clone this repo or copy the `compose.yaml` file out of the `container` directory to your local machine. Edit the compose file to change the environment variables to the values you desire and then save the changes. Once you have made your changes, from the same directory that contains the compose and the env files.

compose.yaml :
```yaml
services:
  ark-ascended:
    image: sknnr/ark-ascended-server:latest
    ports:
      - "7777:7777/udp"
      - "27020:27020/tcp"
    environment:
      - SESSION_NAME=Ark Ascended Containerized
      - SERVER_PASSWORD=PleaseChangeMe
      - SERVER_MAP=TheIsland_WP
      - SERVER_ADMIN_PASSWORD=AlsoChangeMe
      - GAME_PORT=7777
      - RCON_PORT=27020
    volumes:
      - ark-persistent-data:/home/steam/ark/ShooterGame/Saved

volumes:
  ark-persistent-data:

```

To bring the container up:

```bash
docker-compose up -d
```

To bring the container down:

```bash
docker-compose down
```

### Podman

To run the container in Podman, run the following command:

```bash
podman volume create ark-persistent-data
podman run \
  --detach \
  --name Ark-Ascended-Server \
  --mount type=volume,source=ark-persistent-data,target=/home/steam/ark/ShooterGame/Saved \
  --publish 7777:7777/udp \
  --env=SERVER_MAP=TheIsland_WP \
  --env=SESSION_NAME="Ark Ascended Containerized" \
  --env=SERVER_PASSWORD="PleaseChangeMe" \
  --env=SERVER_ADMIN_PASSWORD="AlsoChangeMe" \
  --env=GAME_PORT=7777 \
  docker.io/sknnr/ark-ascended-server:latest
```

### Kubernetes

I've built a Helm chart and have included it in the `helm` directory within this repo. Modify the `values.yaml` file to your liking and install the chart into your cluster. Be sure to create and specify a namespace as I did not include a template for provisioning a namespace.

## Troubleshooting

### Connectivity

If you are having issues connecting to the server once the container is deployed, I promise the issue is not with this image. You need to make sure that the ports 7777/udp and 27020/tcp (or whichever ones you decide to use) are open on your router as well as the container host where this container image is running. You will also have to port-forward the game-port and query-port from your router to the private IP address of the container host where this image is running. After this has been done correctly and you are still experiencing issues, your internet service provider (ISP) may be blocking the ports and you should contact them to troubleshoot.

### Storage

I recommend having Docker or Podman manage the volume that gets mounted into the container. However, if you absolutely must bind mount a directory into the container you need to make sure that on your container host the directory you are bind mounting is owned by 10000:10000 by default (`chown -R 10000:10000 /path/to/directory`). If the ownership of the directory is not correct the container will not start as the server will be unable to persist the savegame.
