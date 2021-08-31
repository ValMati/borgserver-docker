# BORG SERVER

[![.github/workflows/docker-publish.yml](https://github.com/ValMati/borgserver-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/ValMati/borgserver-docker/actions/workflows/docker-publish.yml)

Docker image with openSSH and BorgBackup installed and ready to use as a backup server over SSH.

## Source Code & Image

The code is available on [GitHub](https://github.com/ValMati/borgserver-docker)

With each release a new version of the image is published on [DockerHub](https://hub.docker.com/r/valmati/borgserver)

## Usage

It is recommended to launch the image from a docker-compose as in the [example](docker-compose.yml).

As usual, it is necessary to indicate the image, in this case [valmati/borgserver:latest](https://hub.docker.com/r/valmati/borgserver).

### Hostname

It's important set the hostname because the host keys have information about this.

### Port

The SSH server listens on port 22, but as this port is usually in use by the host it is recommended to use another one, in the example it is 2222.

### Environment

| Variable | Description | Value |
| --- | --- | --- |
| UID / GUD | Inside the container a user and a group are created (*borguser* and *borggroup*) that are the ones that will create the backups. The environment variables *UID* and *GID* are the ids with wich the user and the group are created. It is recommended that theses are those of the host user from witch we want to manage the backups later. | 1000 / 1000 |
| TZ        | Timezone | Europe/Madrid |
| RESTRICT_TO_PATH  | Enable or disable the restriction to the client path. | true |

### Volumes

The *borgserver* container must have access to three volumes:

#### Host Keys (/etc/ssh/host_keys/)

The keys to identify the server are stored in this volume. To avoid receiving a security warning the host keys should be mounted on an external volumen.

When the image is executed, it is checked if these keys already exist and if don't new ones are generated.

#### Authorized Keys (/etc/authorized_keys/)

In this volumen the public keys of the clients must be accessible. In case you want to add or remove a cliente it is not necessary to stop and relaunch the container, just remove or add the publich keys and execute the following command:

```bash
docker exec [ContainerName] /bin/genauthkeys.sh
```

#### Backups (/backups)

This volume is where the backups of the differente clients will be generated. It is essential that this volume is not lost with the destruction of the container because in that case **we will lost our backups**.

## Inspired on

https://github.com/panubo/docker-sshd

https://practical-admin.com/blog/backups-using-borg/