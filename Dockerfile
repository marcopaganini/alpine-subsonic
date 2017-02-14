FROM alpine

MAINTAINER paganini@paganini.net

ENV DEBIAN_FRONTEND noninteractive

# Desired UID & GID
ENV SUBSONIC_UID=2000
ENV SUBSONIC_GID=2000
ENV SUBSONIC_HOME=/var/subsonic
ENV SUBSONIC_VERSION 6.0

# Add subsonic tar.gz
ADD http://subsonic.org/download/subsonic-${SUBSONIC_VERSION}-standalone.tar.gz /tmp/subsonic.tar.gz

# Create a new group 'subsonic' with SUBSONIC_GID, home /var/subsonic.
# Create user 'subsonic' with SUBSONIC_UID, add to that group.
# Create /var/subsonic
# Untar the subsonic tar file into /var/subsonic
# Set permissions.
RUN addgroup -g $SUBSONIC_GID subsonic && \
    adduser -D -H -h $SUBSONIC_HOME -u $SUBSONIC_UID -G subsonic -g "Subsonic User" subsonic && \
    mkdir -p $SUBSONIC_HOME && \
    tar zxvf /tmp/subsonic.tar.gz -C $SUBSONIC_HOME && \
    rm -f /tmp/*.tar.gz && \
    chown subsonic $SUBSONIC_HOME && \
    chmod 0770 $SUBSONIC_HOME

# Install java7, ffmpeg, lame & friends.
RUN apk --update add openjdk7-jre ffmpeg

# Create hardlinks to the transcoding binaries.
# This way we can mount a volume over /var/subsonic.
# Apparently, Subsonic does not accept paths in the Transcoding settings.
# If you mount a volume over /var/subsonic, create symlinks
# <host-dir>/var/subsonic/transcode/ffmpeg -> /usr/local/bin/ffmpeg
# <host-dir>/var/subsonic/transcode/lame -> /usr/local/bin/lame
RUN mkdir -p $SUBSONIC_HOME/transcode && \
    ln /usr/bin/ffmpeg /usr/bin/lame $SUBSONIC_HOME/transcode

VOLUME /var/subsonic

EXPOSE 4040

USER subsonic

COPY startup.sh /startup.sh

CMD []
ENTRYPOINT ["/startup.sh"]
