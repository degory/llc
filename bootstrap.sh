#!/bin/bash
if [ -z "$JOB_NAME" ]; then
    export JOB_NAME=compiler
fi

export PROJECT=$JOB_NAME

if [ ! -d /tmp/lcache-$PROJECT ]; then
    mkdir /tmp/lcache-$PROJECT
fi

pushd jay; make jay; popd; make bootstrap
