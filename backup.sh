#!/bin/bash

DIR=/srv/backup
BIN=/usr/local/sbin
OUT=/var/log/backup_out.log

export DATA=/var/lib/backup
export LOG=/var/log/backup.log

cd $DIR

echo -n " >>>>>  Start backup.sh $1 script " >>$LOG
date >>$LOG
echo -n " >>>>>  Start backup.sh $1 script " >>$OUT
date >>$OUT

if [ -z "$1" ] ; then
    # A könyvtárak vagyis a mentendő host-ok litája
    for h in `ls --file-type -c --hide "*.*" | grep '/' | sed s'/[/]//'`
    do
        echo "Starting $h backup ..." >>$LOG
        $BIN/backup_host.sh $h >>$OUT 2>&1
    done
else
    echo "Starting $1 backup ..." >>$LOG
    $BIN/backup_host.sh $1 >>$OUT 2>&1
fi

echo -n " <<<<<  Finished backup.sh $1 script " >>$LOG
date >>$LOG
echo -n " <<<<<  Finished backup.sh $1 script " >>$OUT
date >>$OUT

