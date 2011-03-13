#!/bin/bash

CAPTURE=$1

let i=1
let last=200
let processes=4

while [ $i -lt $last ] ; do
    let from=i
    let to=i+processes-1
    let t=1

    # echo "running ${processes} tests from ${from} to ${to}..."
    
    for j in `seq ${from} ${to}` ; do
        export TMP=tmp/$t
	if ! [ -d $TMP ] ; then
            mkdir $TMP
	fi
        # echo "running test ${j} in ${TMP}..."

	if [ -d cases/$j ] ; then
   	    export PROCESS=$t
	    ./onetest.sh $j $CAPTURE &
	fi
        let t=t+1
    done

    # echo "waiting for ${processes} tests to complete..."

    let i=i+processes

    wait
done

