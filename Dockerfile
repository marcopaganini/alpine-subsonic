FROM alpine

MAINTAINER paganini@paganini.net

ENV SUBSONIC_VERSION 6.1.6

# Desired UID & GID
ENV SUBSONIC_UID=10000
ENV SUBSONIC_GID=10000

# This is where subsonic will write its state. Should be mapped to a docker
# volume or a location outside the container. The unfortunate name comes from
# the upstream subsonic.sh, which uses SUBSONIC_HOME for a data directory.
ENV SUBSONIC_HOME=/var/subsonic

# Internal home directory for the "subsonic" user (internal to the container).
# and main location for subsonic binaries.
ENV SUBSONIC_BIN=/home/subsonic

# Add subsonic tar.gz
ADD https://sourceforge.net/projects/subsonic/files/subsonic/${SUBSONIC_VERSION}/subsonic-${SUBSONIC_VERSION}-standalone.tar.gz/download /tmp/subsonic.tar.gz

# - Create a new group 'subsonic' with SUBSONIC_GID, home $SUBSONIC_BIN
# - Create the $SUBSONIC_BIN
# - Create user 'subsonic' with SUBSONIC_UID, add to that group.
# - Set permissions of $SUBSONIC_BIN
RUN addgroup -g $SUBSONIC_GID subsonic && \
    adduser -D -H -h $SUBSONIC_BIN -u $SUBSONIC_UID -G subsonic -g "Subsonic User" subsonic && \
    mkdir -p $SUBSONIC_BIN && \
    tar zxvf /tmp/subsonic.tar.gz -C $SUBSONIC_BIN && \
    rm -f /tmp/*.tar.gz && \
    chown subsonic $SUBSONIC_BIN && \
    chmod 0770 $SUBSONIC_BIN

# Create subsonic data directory ($SUBSONIC_HOME). This is where subsonic stores
# its state information. This is normally overriden with --volume, but we create
# it here in case the user prefers to save state in the container itself.
RUN mkdir -p $SUBSONIC_HOME && \
    chown subsonic $SUBSONIC_HOME && \
    chmod 0770 $SUBSONIC_HOME

# Install java8, ffmpeg, lame & friends.
RUN apk --update add openjdk8-jre ffmpeg

# Create hardlinks to the transcoding binaries so we can mount a volume
# over $SUBSONIC_HOME. If you mount a volume over $SUBSONIC_HOME, create
# symlinks on the host.
#
# TODO: Investigate a better way to do this.
RUN mkdir -p $SUBSONIC_HOME/transcode && \
    ln /usr/bin/ffmpeg /usr/bin/lame $SUBSONIC_HOME/transcode

VOLUME $SUBSONIC_HOME

EXPOSE 4040

USER subsonic

COPY startup.sh /startup.sh

CMD []
ENTRYPOINT ["/startup.sh"]
