ROM balenalib/raspberry-pi:build as build

ARG arch
RUN test -n "${arch}"
RUN echo ${arch}

ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 10
ENV ENIGMA_BRANCH 0.0.10-alpha


RUN apt-get update && apt-get upgrade && apt-get install -y --no-install-recommends \
        cvs \
        zip \
        unzip \
        libnspr4-dev \
        libncurses5-dev \
        git \
        curl \
        build-essential \
        python \
        libssl-dev \
        lrzsz \
        arj \
        lhasa \
        unrar-free \
        p7zip-full \
    && mkdir build \
    && mkdir build/sbbs \
    && wget 'http://cvs.synchro.net/cgi-bin/viewcvs.cgi/*checkout*/install/GNUmakefile' -O /build/sbbs/GNUmakefile \
    && cd /build/sbbs/ \
    && make \
    && cd .. \
    && curl -O https://raw.githubusercontent.com/creationix/nvm/master/install.sh \
    && chmod +x install.sh && ./install.sh \
    && . ~/.nvm/nvm.sh && nvm install $NODE_VERSION && nvm alias default $NODE_VERSION && npm install -g pm2 \
    && git clone https://github.com/NuSkooler/enigma-bbs.git --depth 1 --branch $ENIGMA_BRANCH \
    && cd /build/enigma-bbs && npm install --only=production 


FROM balenalib/raspberry-pi:run

ARG arch

# sexyz
COPY --from=build /build/sbbs/src/sbbs3/gcc.linux.${arch}.exe.release/sexyz /usr/local/bin/

# nvm
COPY --from=build /root/.nvm /root/.nvm

# enigma-bbs
COPY --from=build /build/enigma-bbs /enigma-bbs

# enigma storage mounts
VOLUME /enigma-bbs/art
VOLUME /enigma-bbs/config
VOLUME /enigma-bbs/db
VOLUME /enigma-bbs/filebase
VOLUME /enigma-bbs/logs
VOLUME /enigma-bbs/mods
VOLUME /mail

# copy base config
COPY config/* /enigma-bbs/misc/

# set up config init script
COPY scripts/enigma_config.sh /enigma-bbs/misc/enigma_config.sh
RUN chmod +x /enigma-bbs/misc/enigma_config.sh

# Enigma default port
EXPOSE 8888

WORKDIR /enigma-bbs

ENTRYPOINT ["/bin/bash", "-c", "cd /enigma-bbs && ./misc/enigma_config.sh && source ~/.nvm/nvm.sh && exec pm2-docker ./main.js"]
