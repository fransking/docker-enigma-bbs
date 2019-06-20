# ENiGMA BBS

Docker container that runs [ENiGMA½ BBS Software](https://github.com/NuSkooler/enigma-bbs). All required packages for 
ENiGMA½ to run successfully are included, and pm2-docker is used to manage the Node.js process.

## Quick Start

This container image is available from the Docker Hub.

Assuming that you have Docker installed, run the following command:

````bash
docker run -d \
  -p 8888:8888 \
  fransking/enigma-bbs-arm32v6
````

or 

````bash
docker run -d \
  -p 8888:8888 \
  fransking/enigma-bbs-arm32v7
````

depending on whether you have a raspberry pi 1/zero (armv6) or later model (armv7)

As no config has been supplied, the container will use a basic one so that it starts successfully. ENiGMA½ listens via
telnet on port 8888. Connect and try it out!

## A Proper Setup

So you've decided ENiGMA½ (and Docker) is for you, and you want a "proper" setup. There are a few things you need to do:

1. Create a directory on your Docker host machine to store ENiGMA½ data, e.g. ~/my_sweet_bbs. Within that, create directories
for the mountable volumes - art, config, db, filebase, logs, mail and mods.

2. Create a config.hjson, menu.hjson and prompt.hjson files within the config directory you created. See the ENiGMA½ docs for available options.

3. Copy any customisations such as themes and mods, to the mods directory.

    You should end up with a structure something like the following:
    
    ````text
    ├── config
    │   ├── config.hjson
    │   ├── my_menus.hjson
    │   └── my_prompts.hjson
    ├── db
    ├── www (note you should copy files from https://github.com/NuSkooler/enigma-bbs/tree/master/www)
    ├── filebase
    ├── logs
    ├── mail
    ├── mods
    │   └── awesome_mod
    └── art
        ├── general
        └── themes
            └── sick_theme
    ````

4. Start the container:

    ````bash
    docker run -d \
        -p 8888:8888 \
        -v ~/my_sweet_bbs/art:/enigma-bbs/art \
        -v ~/my_sweet_bbs/config:/enigma-bbs/config \
        -v ~/my_sweet_bbs/db:/enigma-bbs/db \
        -v ~/my_sweet_bbs/www:/enigma-bbs/www \
        -v ~/my_sweet_bbs/filebase:/enigma-bbs/filebase \
        -v ~/my_sweet_bbs/logs:/enigma-bbs/logs \
        -v ~/my_sweet_bbs/filebase:/enigma-bbs/filebase \
        -v ~/my_sweet_bbs/mods:/enigma-bbs/mods \
        -v ~/my_sweet_bbs/mail:/mail \
        fransking/enigma-bbs-arm32v6|fransking/enigma-bbs-arm32v7
    ````

## Volumes

The following volumes are mountable:

| Volume                  | Usage                                                                |
|:------------------------|:---------------------------------------------------------------------|
| /enigma-bbs/art         | Art, themes, etc                                                     |
| /enigma-bbs/config      | Config such as config.hjson, menu.hjson, prompt.hjson, SSL certs etc |
| /enigma-bbs/db          | ENiGMA databases                                                     |
| /enigma-bbs/filebase    | Filebase                                                             |
| /enigma-bbs/logs        | Logs                                                                 |
| /enigma-bbs/mods        | ENiGMA mods                                                          |
| /mail                   | FTN mail (for use with an external mailer)                           |
| /www                    | static web content                                                   |

## TODO

* Any more space optimisations?
* Install packages for mods on container init

## License 

This project is licensed under the [BSD 2-Clause License](LICENSE).
