#!/bin/bash

if [ -z "$BUILD_WITH" ]; then
    BUILD_WITH="ghul/ex:stable"
fi

docker run -v $WORKSPACE:/home/dev/source -w /home/dev/source -u `id -u`:`id -g` $BUILD_WITH /bin/bash -c "./clean.sh && ./build.sh"


