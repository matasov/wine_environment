FROM ubuntu:18.04 AS launcher

RUN apt-get update && apt-get install -y locales software-properties-common wget && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
    && apt-get update \
    && apt-get install -y openjdk-8-jre-headless \
    && apt-get install -y make \
    && apt-get -y install openssh-client \
    && apt-get -y install sshpass \
    && apt-get -y install iputils-ping \
    && apt-get install -y nsis

RUN apt-get install -y cmake=3.10.2-1ubuntu2.18.04.1 \
    && apt-get install -y \
    gcc-4.8 g++-4.8 gcc-4.8-base \
    gcc-5 g++-5 gcc-5-base \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 100 \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

USER root
ADD . /

RUN tar -xf /launch4j-3.12-linux-x64.tgz

ENV DEBIAN_FRONTEND noninteractive

# wine settings
ENV WINEARCH win32
ENV WINEDEBUG fixme-all
ENV WINEPREFIX /wine

RUN set -x \
    && dpkg --add-architecture i386 \
    && apt-get update -qy \
    && apt-get install --no-install-recommends -qfy wine32-development wine-development wget ca-certificates \
    && apt-get clean \
    && wget -q http://downloads.sourceforge.net/project/nsis/NSIS%203/3.03/nsis-3.03-setup.exe \
    && wine nsis-3.03-setup.exe /S \
    && while pgrep wineserver >/dev/null; do echo "Waiting for wineserver"; sleep 1; done \
    && rm -rf /tmp/.wine-* \
    && echo 'wine '\''C:\Program Files\NSIS\makensis.exe'\'' "$@"' > /usr/bin/makensis \
    && chmod +x /usr/bin/*

VOLUME /wine/drive_c/src/
