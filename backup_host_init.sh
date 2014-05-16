#!/bin/sh

# Host and dir(base) name
HOST=$1

DIR=/srv/backup
DATA=/var/lib/backup
LOG=/var/log/backup_init.log

cd $DIR

echo -n "Start $HOST first backup " >>$LOG
date >>$LOG

if [ ! -d $HOST ]
then
    mkdir $HOST
fi
if [ ! -f $DATA/exclude-${HOST}.txt ] 
then
    echo "Exclude file ($DATA/exclude-${HOST}.txt) not found, create default content." >>$LOG
    cp $DATA/exclude-default.txt $DATA/exclude-${HOST}.txt
fi

rsync --exclude-from $DATA/exclude-${HOST}.txt -a --delete --delete-excluded ${HOST}:/ $HOST
RESULT=$?
date >$HOST/BackupTimeStamp

echo -n "End $HOST first backup ($RESULT) " >>$LOG
date >>$LOG


