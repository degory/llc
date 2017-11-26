#!/bin/bash
docker run -v $WORKSPACE:/home/dev/source -w /home/dev/source -u `id -u`:`id -g` -t ghul/ex /bin/bash -c "./clean.sh && ./bootstrap.sh"


