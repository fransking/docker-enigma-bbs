#!/bin/bash

if [ $(arch) == "armv6l" ] 
then
    suffix="arm32v6"
    node_mirror="https://unofficial-builds.nodejs.org/download/release"
elif [ $(arch) == "armv7l" ]
then
    suffix="arm32v7"
    node_mirror=
else
   echo "$(arch) not supported"
   exit -1
fi

docker build \
--build-arg arch=$(arch) \
--build-arg node_mirror=$node_mirror \
-t fransking/enigma-bbs-$suffix .
