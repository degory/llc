#!/bin/bash
docker run -v `pwd`:/home/dev/source/ -w /home/dev/source -u `id -u`:`id -g` -it docker.giantblob.com/ex /bin/bash -c "make clean"
