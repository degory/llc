#!/bin/bash
MSYS_NO_PATHCONV=1 \
docker run -v `pwd`:/home/dev/source/ -w /home/dev/source -u `id -u`:`id -g` -it docker.giantblob.com/ex /bin/bash -c "./clean.sh && ./bootstrap.sh"
