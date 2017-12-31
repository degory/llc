#!/bin/bash
docker run -v `pwd`:/home/dev/source/ -w /home/dev/source -u `id -u`:`id -g` -ghul/ex:stable /bin/bash -c "make clean"
