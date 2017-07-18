#!/bin/bash
if [ -z "$JOB_NAME" ]; then
    export JOB_NAME=compiler
fi

if [ ! -d /tmp/lcache-$JOB_NAME ]; then
    mkdir /tmp/lcache-$JOB_NAME
fi

pushd jay; make jay; popd; make bootstrap