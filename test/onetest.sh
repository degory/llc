FAILED=0
NAME=$1
CASE=cases/$NAME

if [ -f $CASE/lflags ] ; then
    LFLAGS="$LFLAGS `cat $CASE/lflags`"
fi

if [ "$PROCESS" != "" ] ; then
    LCACHE="/tmp/lcache-test${PROCESS}"
    LFLAGS="$LFLAGS -p test${PROCESS}"
    BINARY="binary${PROCESS}"
else 
    LCACHE="/tmp/lcache"
    BINARY="binary"
fi

if ! [ -d $LCACHE ] ; then
    mkdir $LCACHE
fi

rm -f $BINARY ${BINARY}.bc ${BINARY}.lh ${LCACHE}/* ${TMP}/*

if [ "$LC"="" ] ; then
    LC=lc
fi

# echo "${NAME}: compile ${CASE}/test.l as ${BINARY}..."
$LC $LFLAGS $CASE/test.l -o ${BINARY} 2>$TMP/err_out
grep error: $TMP/err_out | sort >$TMP/err
grep warn: $TMP/err_out | sort >$TMP/warn
if [ "$2" = "capture" ]; then
    cp $TMP/err $CASE/err
    cp $TMP/warn $CASE/warn
else
    if ! diff $CASE/err $TMP/err >$TMP/err_diff ; then
       FAILED=1
       echo "${NAME}: compile error output differs"
       # cat $TMP/err_diff
       cp $TMP/err $CASE/err.test
       cp $TMP/err_diff $CASE/err.diff
    fi

    if ! diff $CASE/warn $TMP/warn >$TMP/warn_diff ; then
       FAILED=1
       echo "${NAME}: compile warn output differs"
       # cat $TMP/warn_diff
       cp $TMP/warn $CASE/warn.test
       cp $TMP/warn_diff $CASE/warn.diff
    fi
fi  

if [ -f ./${BINARY} ] ; then
    # echo "${NAME}: compile produced binary ${BINARY}"
    #ls ./binary
    #./timeout.sh 60 ./binary    
    ./timeout.sh 15 ./${BINARY} 2>&1 | cat >$TMP/out
else
    echo "${NAME}: compile failed to produce binary ${BINARY}"
    exit 1
fi

if [ "$2" = "capture" ]; then
    cp $TMP/out $CASE/out
else
    if ! diff $CASE/out $TMP/out >$TMP/out_diff ; then
       FAILED=1
       echo "${NAME}: test output differs"
       cp $TMP/out $CASE/out.test
       cp $TMP/out_diff $CASE/out.diff
       # cat $TMP/out_diff
    fi
fi

exit $FAILED

