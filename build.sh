#!/bin/bash
if [ -z "$JOB_NAME" ]; then
    export JOB_NAME=compiler
fi

export PROJECT=$JOB_NAME

if [ ! -d /tmp/lcache-$PROJECT ]; then
    mkdir /tmp/lcache-$PROJECT
fi

echo lcache is /tmp/lcache-$PROJECT

pushd jay; make jay; popd; make lc.zip
