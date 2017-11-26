#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "no image name specified"
    exit 1
fi

if [ -z "$BUILD_NUMBER" ]; then
    echo "Building test version of $1..."
    
    docker build --pull $1 -t ghul/$1:test -t ghul/$1:latest
    docker push ghul/$1:test
    docker push ghul/$1:latest    
else
    echo "Building version $BUILD_NUMBER of $1..."
    
    docker build --pull $1 -t ghul/$1:$BUILD_NUMBER -t ghul/$1:latest
    docker push ghul/$1:$BUILD_NUMBER
    docker push ghul/$1:latest   
fi




