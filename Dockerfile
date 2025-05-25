ARG docker_arch

FROM node:22-bookworm-slim as build

ENV ENIGMA_BRANCH master

ARG arch
RUN test -n "${arch}"

# update base package
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove -y

# install build dependencies
RUN apt-get install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    git \
    unzip \
    libnspr4-dev \
    autoconf \
    pkg-config \
    python3 \
    zip

# download Synchronet source for sexys
RUN mkdir build && \
    cd /build && \
    git clone https://gitlab.com/SynchronetBBS/sbbs.git && \
    cd sbbs && \ 
    cd 3rdp/dist && \ 
    unzip -d cryptlib cryptlib.zip  

# build sexyz
# we don't want to build cryptlib or spidermonkey just get enough of the build environment to compile sexys
# without writing our own makefiles
RUN cd /build/sbbs/3rdp/build && \
    sed -i '/$(MAKE)/d' GNUmakefile && \
    mkdir /build/sbbs/src/sbbs3/gcc.linux.${arch}.exe.debug && \
    cd /build/sbbs/src/sbbs3 && \
    make hash && \
    make git_branch.h git_hash.h && \
    make sexyz JSINCLUDE=/build/sbbs/3rdp/src/mozjs/js-1.8.5/js/src CRYPTLIBINCLUDE=/build/sbbs/3rdp/dist/cryptlib

# build enigma
#RUN cd /build && \
#    git clone https://github.com/NuSkooler/enigma-bbs.git --branch $ENIGMA_BRANCH && \
#    cd /build/enigma-bbs &&  \ 
#    git reset --hard f3d0da2 && \

RUN cd /build && \
    git clone https://github.com/NuSkooler/enigma-bbs.git --depth 1 --branch $ENIGMA_BRANCH && \
    cd /build/enigma-bbs &&  \ 
    npm install -g npm@7 && \
    npm install --only=production && \
    npm install -g pm2 && \
    npm cache clean --force


FROM node:22-bookworm-slim

ARG arch

# update base package
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove -y

# install dependencies
RUN apt-get install -y --no-install-recommends \
    ca-certificates \
    zip \
    unzip \
    lhasa \
    unrar-free \
    p7zip-full \
    arj \
    exiftool \
    lrzsz \
    xdms

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
VOLUME /tmp

# copy base config
COPY config/* /enigma-bbs/misc/

# set up config init script
COPY scripts/enigma_config.sh /enigma-bbs/misc/enigma_config.sh
RUN chmod +x /enigma-bbs/misc/enigma_config.sh

# add trap script for debugging shell commands
COPY scripts/trap.sh /bin

# Enigma default port
EXPOSE 8888

WORKDIR /enigma-bbs

ENTRYPOINT ["/bin/bash", "-c", "cd /enigma-bbs && ./misc/enigma_config.sh && exec pm2-docker ./main.js"]
