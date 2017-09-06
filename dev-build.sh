#!/bin/bash
mkdir -p /tmp/lcache-compiler
docker run -v /tmp/lcache-compiler:/tmp/lcache-compiler -v `pwd`:/home/dev/source/ -w /home/dev/source --user docker -u `id -u`:`id -g` -it docker.giantblob.com/ex /bin/bash -c "./clean.sh && ./build.sh"
