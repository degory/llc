#!/bin/bash
if [ -z $BUILD_NUMBER ] ; then
    echo BUILD_NUMBER not set
    exit 1
fi
docker tag ghul/base:$BUILD_NUMBER ghul/base:stable
docker push ghul/base:stable
docker tag ghul/llc:$BUILD_NUMBER ghul/llc:stable
docker push ghul/llc:stable
docker tag ghul/ex:$BUILD_NUMBER ghul/ex:stable
docker push ghul/ex:stable



