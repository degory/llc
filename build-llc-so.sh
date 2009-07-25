mkdir /tmp/lcache-lib
rm -f /tmp/lcache-lib/*
llc -p lib -O1Ls -d main.l -l amd64 lang.ll -o /usr/lang/lib/unsafe/llc
