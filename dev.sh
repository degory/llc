#!/bin/bash
docker run -v `pwd`:/home/dev/source/ -w /home/dev/source --user docker -u `id -u`:`id -g` -it ghul/ex:stable /bin/bash
