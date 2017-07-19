#!/bin/bash
if [ -z "$JOB_NAME" ]; then
    export JOB_NAME=compiler
fi

export PROJECT=$JOB_NAME

if [ -d /tmp/lcache-$PROJECT ]; then
    rm -rf /tmp/lcache-$PROJECT
fi

make clean
