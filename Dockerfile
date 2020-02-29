ARG docker_arch

FROM ${docker_arch}/node:12-alpine as build

ENV ENIGMA_BRANCH 0.0.11-beta

ARG arch
RUN test -n "${arch}"

RUN apk add --update build-base \
        bash \
        curl \
        cvs \
        git \
        pkgconfig \
        autoconf \
        perl \
        python \
        zip \
        patch \
        nspr-dev && \
        rm -rf /var/cache/apk/*

RUN mkdir build && \
    mkdir build/sbbs && \
    cd /build/sbbs/ && \
    wget 'ftp://vert.synchro.net/Synchronet/ssrc316c.tgz' && \
    tar xzfv ssrc316c.tgz && \
    cd 3rdp/dist && \ 
    unzip -d cryptlib cryptlib.zip  

# build sexyz
# we don't want to build cryptlib or spidermonkey just get enough of the build environment to compile sexys
# without writing our own makefiles
RUN cd /build/sbbs/3rdp/build && \
    sed -i '/$(MAKE)/d' GNUmakefile && \
    make libmozjs && \
    touch /build/sbbs/3rdp/src/mozjs/js-1.8.5/js/src/jsautocfg.h && \
    sed -i 's/PTHREAD_MUTEX_RECURSIVE_NP/PTHREAD_MUTEX_RECURSIVE/g' /build/sbbs/src/xpdev/threadwrap.c && \
    mkdir /build/sbbs/src/sbbs3/gcc.linux.${arch}.exe.debug && \
    cd /build/sbbs/src/sbbs3 && \
    make sexyz JSINCLUDE=/build/sbbs/3rdp/src/mozjs/js-1.8.5/js/src CRYPTLIBINCLUDE=/build/sbbs/3rdp/dist/cryptlib

# build xdms
RUN cd /build && \
    wget https://zakalwe.fi/~shd/foss/xdms/xdms-1.3.2.tar.bz2 && \
    tar xjfv xdms-1.3.2.tar.bz2 && \
    cd xdms-1.3.2 && \
    ./configure && \
    make install

# build enigma
RUN cd /build && \
    git clone https://github.com/NuSkooler/enigma-bbs.git --depth 1 --branch $ENIGMA_BRANCH && \
    cd /build/enigma-bbs && npm install --only=production && \
    npm install -g pm2 && \
    npm cache clean --force



FROM ${docker_arch}/node:12-alpine

ARG arch

RUN apk add --update bash \
        zip \
        unzip \
        lha \
        unrar \
        p7zip \
        unarj \
	    perl-image-exiftool && \
        apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        lrzsz && \
        rm -rf /var/cache/apk/*

# node libs
COPY --from=build /usr/local/lib/node_modules /usr/local/lib/node_modules

# node binaries
COPY --from=build /usr/local/bin /usr/local/bin

# sexyz
COPY --from=build /build/sbbs/src/sbbs3/gcc.linux.${arch}.exe.debug/sexyz /usr/local/bin/

# enigma-bbs
COPY --from=build /build/enigma-bbs /enigma-bbs

# enigma storage mounts
VOLUME /enigma-bbs/art
VOLUME /enigma-bbs/config
VOLUME /enigma-bbs/db
VOLUME /enigma-bbs/filebase
VOLUME /enigma-bbs/logs
VOLUME /enigma-bbs/mods
VOLUME /enigma-bbs/www
VOLUME /mail

# copy base config
COPY config/* /enigma-bbs/misc/

# set up config init script
COPY scripts/enigma_config.sh /enigma-bbs/misc/enigma_config.sh
RUN chmod +x /enigma-bbs/misc/enigma_config.sh

# Enigma default port
EXPOSE 8888

WORKDIR /enigma-bbs

ENTRYPOINT ["/bin/bash", "-c", "cd /enigma-bbs && ./misc/enigma_config.sh && exec pm2-docker ./main.js"]
