#!/bin/bash
docker run -v $WORKSPACE:/home/dev/source -w /home/dev/source -u `id -u`:`id -g` -t docker.giantblob.com/ex /bin/bash -c "./clean.sh && ./build.sh"


