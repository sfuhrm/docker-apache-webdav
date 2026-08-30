# Apache WebDav Server (built from the Alpine image)

[![Docker Image CI](https://github.com/sfuhrm/docker-apache-webdav/actions/workflows/docker-image.yml/badge.svg)](https://github.com/sfuhrm/docker-apache-webdav/actions/workflows/docker-image.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/sfuhrm/docker-apache-webdav)](https://hub.docker.com/r/sfuhrm/docker-apache-webdav)
[![Docker Image Size](https://img.shields.io/docker/image-size/sfuhrm/docker-apache-webdav/latest)](https://hub.docker.com/r/sfuhrm/docker-apache-webdav)
[![GitHub release](https://img.shields.io/github/v/release/sfuhrm/docker-apache-webdav)](https://github.com/sfuhrm/docker-apache-webdav/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Incredibly secure, fast WebDav Server, built from Alpine image - bare minimum with no bells and whistles.

> This is a variant of https://github.com/sfuhrm/docker-nginx-webdav with the following changes:
> * using Apache httpd instead of nginx,
> * increasing the image layers and size (
nginx image: [![Docker Image Size](https://img.shields.io/docker/image-size/sfuhrm/docker-nginx-webdav/latest)](https://hub.docker.com/r/maltokyo/docker-nginx-webdav),
this image: [![Docker Image Size](https://img.shields.io/docker/image-size/sfuhrm/docker-apache-webdav/latest)](https://hub.docker.com/r/sfuhrm/docker-apache-webdav)),
> * no more plain passwords, this image only deals with hashed htpasswd files

## Docker tags

Different tags mean different versions.
All tags on Dockerhub have passed the internal tests.
Usually you want to go with the `nightly` version to get the newest
Alpine Linux base. 

Overview of tag dates:

| Tag   |      Date      |
|----------|:-------------:|
| nightly | ![Dockerhub Nightly Push](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fhub.docker.com%2Fv2%2Fnamespaces%2Fsfuhrm%2Frepositories%2Fdocker-apache-webdav%2Ftags%2Fnightly&query=%24.tag_last_pushed&prefix=on%20&logo=docker&label=dockerhub%20nightly%20push&cacheSeconds=600) |
| master | ![Dockerhub Master Push](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fhub.docker.com%2Fv2%2Fnamespaces%2Fsfuhrm%2Frepositories%2Fdocker-apache-webdav%2Ftags%2Fmaster&query=%24.tag_last_pushed&prefix=on%20&logo=docker&label=dockerhub%20master%20push&cacheSeconds=600) |
| latest | ![Dockerhub Latest Push](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fhub.docker.com%2Fv2%2Fnamespaces%2Fsfuhrm%2Frepositories%2Fdocker-apache-webdav%2Ftags%2Flatest&query=%24.tag_last_pushed&prefix=on%20&logo=docker&label=dockerhub%20latest%20push&cacheSeconds=600) |

The meanings of the tags:

| Tag   |      Meaning      |
|----------|:-------------:|
| `nightly` | Nightly build of the master branch, usually up-to-date Alpine Linux verison. |
| `master` |  Last master branch commit. Same features as `nightly`, but based on an older Appine Linux. |
| `latest` |  Latest release per Github tag, *not* necessarily the most up-to-date Alpine Linux version! |
| `v1.0.0` |  Version snapshot rebuilt nightly. Used to go back to a previous well-known state. |

## How to use this image
```console
$ docker run --name keepass-webdav -p 8080:8080 -v /path/to/your/keepass/files/:/media/data -d sfuhrm/docker-apache-webdav
```

Or use the [docker-compose](./docker-compose.yml) file included in this repository.

No built-in TLS support. Reverse proxy with TLS recommended.

## Volumes
- `/media/data` - served directory, needs to be accessible to the `apache` user with uid `100` and gid `100`.

## Authentication

By default the server runs without authentication. To restrict access to
authorized users, provide a htpasswd file and point the `$HTPASSWD_FILE`
environment variable at its path inside the container.

The htpasswd file must use Apache's `htpasswd` format (`username:hash`). You can
create one on your host with the `htpasswd` utility:

```console
$ htpasswd -c htpasswd webdav
```

Then mount it into the container and reference it:

```console
$ docker run --name webdav -p 8080:8080 \
    -v /path/to/your/shared/files/:/media/data \
    -v /path/to/htpasswd:/etc/webdav/htpasswd:ro \
    -e HTPASSWD_FILE=/etc/webdav/htpasswd \
    -d sfuhrm/docker-apache-webdav
```

## Configuration

### Maximum upload size

By default the server limits request bodies to 1 GiB (`1073741824` bytes) to
bound disk-fill denial-of-service. Override the limit with the `MAX_UPLOAD_SIZE`
environment variable (bytes), or set `0` to disable the limit.

## Docker compose

Or use docker-compose example with a htpasswd secret
```nano
version: "3.9"
name: webdav
secrets:
  HTPASSWD_SC:
    file: <path-to-your-htpasswd>/htpasswd
services:
  docker-apache-webdav:
    #image: sfuhrm/docker-apache-webdav
    build: .
    container_name: webdav
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    ports:
      - "8080:8080"
    volumes:
      - "<path-you-want-to-share>:/media/data"
    secrets:
      - HTPASSWD_SC
    environment:
      - HTPASSWD_FILE=/run/secrets/HTPASSWD_SC

```
