#!/bin/bash
docker run -v $WORKSPACE:/home/dev/source -w /home/dev/source -u `id -u`:`id -g` ghul/ex:stable /bin/bash -c "./clean.sh && ./build.sh"


