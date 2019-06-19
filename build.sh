#!/bin/bash

if [ $(arch) == "armv6l" ] 
then
    suffix="arm32v6"
elif [ $(arch) == "armv7l" ]
then
    suffix="arm32v7"
else
   echo "$(arch) not supported"
   exit -1
fi

docker build --build-arg arch=$(arch) -t fransking/enigma-bbs-$suffix .