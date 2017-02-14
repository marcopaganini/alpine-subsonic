# alpine-subsonic

This repository contains configuration to build a
[Subsonic](http://subsonic.org) media streamer [Docker](http://docker.io)
container. This work was derived from [Michael
Scherig](https://github.com/mschuerig)'s [Subsonic Docker
Image](https://github.com/mschuerig/subsonic-docker-image) repo, but uses
Alpine Linux as the base container for a smaller footprint (about 250M vs 512M
for the Debian based version).


## Versions used

* Subsonic 6.0 (http://www.subsonic.org)
* Alpine Linux
* Runs as user subsonic (UID 10000)
* Drop-in replacement for Michael's [Debian Subsonic](https://hub.docker.com/r/mschuerig/debian-subsonic/) image.

## Installing

Install directly from Docker hub with:

```shell
$ docker pull mpaganini/alpine-subsonic
```

## Building your own image

It is also possible to build your own image:

```shell
$ git clone http://github.com/marcopaganini/alpine-docker-image.git
$ cd alpine-docker-image
$ ./build.sh
```

## Running subsonic in a container

* Create user subsonic on your host computer, uid 10000

* We assume your media is under `/var/music_on_host` and can be read by uid
  10000 on the host computer.  (either chmod your entire media library o+rX or
  set it to the correct uid/gid).

* We'll save state under `/var/subsonic` on the *host* computer. This makes it easier
  to update the containers and backup state information.

  $ mkdir /var/subsonic
  $ chown subsonic /var/subsonic
  $ chmod o+rwx /var/subsonic

* Start the container:

```shell
$ docker run \
  --detach \
  --publish 4040:4040 \
  --volume "/var/music_on_host:/var/music:ro" \
  --volume "/var/subsonic:/var/subsonic" \
  mpaganini/alpine-subsonic

```

## Acknowledgements

Again, my thanks to [Michael Schuerig](https://github.com/mschuerig) for the idea.

## Feedback

If you find bugs, open a bug in Github or send a Change request with a fix. Feedback
is always appreciated.
