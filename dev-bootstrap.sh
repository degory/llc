#!/bin/bash
docker run -v `pwd`:/home/dev/source/ -w /home/dev/source --user dev -it docker.giantblob.com/dev /bin/bash -c "mkdir /tmp/lcache-compiler; pushd jay; make jay; popd; make bootstrap"
