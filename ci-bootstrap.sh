#!/bin/bash
docker run -v /var/lib/jenkins/workspace/:/var/lib/jenkins/workspace/ -w $WORKSPACE --user docker -u `id -u`:`id -g` -t docker.giantblob.com/ex /bin/bash -c "./clean.sh && ./bootstrap.sh"


