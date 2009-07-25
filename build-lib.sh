#!/bin/bash
mkdir /tmp/lcache-lib
rm -f /tmp/lcache-lib/*
echo llc -O1Ls -p lib lib.l -o /usr/lang/lib/unsafe/lang
llc -O1Ls -p lib lib.l -o /usr/lang/lib/unsafe/lang
