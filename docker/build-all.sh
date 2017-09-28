#!/bin/bash
set -e
./build.sh base
./build.sh llc
./build.sh ex
./build.sh build
./build.sh dev



