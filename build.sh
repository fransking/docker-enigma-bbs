#!/bin/bash

arch=$(arch)

if [ $arch == "armv6l" ] 
then
    docker_arch="arm32v6"
    
elif [ $arch == "armv7l" ]
then
    docker_arch="arm32v7"
elif [ $arch == "x86_64" ]
then
    docker_arch="amd64"
    arch="x64"
else
   echo "$arch not supported"
   exit -1
fi

docker build \
--no-cache \
--build-arg docker_arch=$docker_arch \
--build-arg arch=$arch \
-t fransking/enigma-bbs-$docker_arch .

docker image inspect fransking/enigma-bbs-$docker_arch:latest --format='{{.Size}}'
