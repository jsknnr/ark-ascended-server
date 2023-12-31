FROM debian:12

ENV DEBIAN_FRONTEND "noninteractive"
ENV STEAM_PATH "/home/steam/.local/share/Steam"
ENV ARK_PATH "/home/steam/ark"
ENV GE_PROTON_VERSION "8-23"
ENV GE_PROTON_URL "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton${GE_PROTON_VERSION}/GE-Proton${GE_PROTON_VERSION}.tar.gz"
ENV STEAM_COMPAT_CLIENT_INSTALL_PATH "$STEAM_PATH"
ENV STEAM_COMPAT_DATA_PATH "$STEAM_PATH/steamapps/compatdata/2430930"

RUN groupadd -g 1000 steam \
    && useradd -g 1000 -u 1000 -m steam \
    && apt-get update \
    && apt-get install -y \
        apt-utils \
        software-properties-common \
        ca-certificates \
        curl \
        wget \
        procps \
        net-tools \
        vim \
        locales \
        supervisor \
    && echo 'LANG="en_US.UTF-8"' > /etc/default/locale \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && dpkg --add-architecture i386 \
    && sed -i 's#^Components: .*#Components: main non-free contrib#g' /etc/apt/sources.list.d/debian.sources \
    && echo steam steam/question select "I AGREE" | debconf-set-selections \
    && echo steam steam/license note '' | debconf-set-selections \
    && apt-get update \
    && apt-get install -y \
        lib32gcc-s1 \
        steamcmd \
    && ln -s /usr/games/steamcmd /usr/bin/steamcmd \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove -y

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

USER steam

RUN mkdir "$ARK_PATH" \
    && mkdir -p "${ARK_PATH}/ShooterGame/Saved" \
    && mkdir -p "${STEAM_PATH}/compatibilitytools.d" \
    && mkdir -p "${STEAM_PATH}/steamapps/compatdata" \
    && wget "$GE_PROTON_URL" -O "/home/steam/GE-Proton${GE_PROTON_VERSION}.tgz" \
    && tar -x -C "${STEAM_PATH}/compatibilitytools.d/" -f "/home/steam/GE-Proton${GE_PROTON_VERSION}.tgz" \
    && cp -r "${STEAM_PATH}/compatibilitytools.d/GE-Proton${GE_PROTON_VERSION}/files/share/default_pfx" "${STEAM_PATH}/steamapps/compatdata/2430930" \
    && rm "/home/steam/GE-Proton${GE_PROTON_VERSION}.tgz"
    
ADD startup.sh /home/steam/startup.sh

WORKDIR /home/steam

CMD ["/home/steam/startup.sh"]
