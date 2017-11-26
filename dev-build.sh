#!/bin/bash
MSYS_NO_PATHCONV=1 \
docker run -v `pwd`:/home/dev/source/ -w /home/dev/source -u `id -u`:`id -g` -t ghul/ex /bin/bash -c "./clean.sh && ./build.sh"
