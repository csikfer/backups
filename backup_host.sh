#!/bin/bash

#TEST="n"

if [ "$TEST" == "Y" ]
then
    echo "Running test mode ..."
    LOG="test.log"
    DATA="."
fi

# Host and dir(base) name
HOST=$1

# Számláló fájl nevek
FACNT=$DATA/$HOST.Acnt
FBCNT=$DATA/$HOST.Bcnt

MAXCT=8
FIRST=1

if [ "$TEST" == "Y" ]
then
    if [ -f $FACNT ] ; then
        echo -n "$FACNT = "; cat $FACNT;
    else
        echo "$FACNT file not found.";
    fi
    if [ -f $FBCNT ] ; then
        echo -n "$FBCNT = "; cat $FBCNT;
    else
        echo "$FBCNT file not found.";
    fi
    echo -n "DIR : "
    ls -d $HOST*
fi


# Roll
# $1 Kiterjesztés betüjele
# $2 Előző arhívum btüjele
roll()
{
    echo "Rolling $1 ..." >>$LOG
    if [ "$TEST" == "Y" ] ; then
        echo "Rolling $1 $2 ..."
    fi
    rm -rf $HOST.$1$MAXCT >/dev/null 2>&1
    for (( n=$MAXCT; $n>$FIRST; n=$n-1 )) do
        old=`expr $n - 1`
        if [ "$TEST" == "Y" ] ; then
            echo "mv -f $HOST.$1$old $HOST.$1$n"
        fi
        if [ -d $HOST.$1$old ]; then
	    mv -f $HOST.$1$old $HOST.$1$n
        elif [ "$TEST" == "Y" ] ; then
            echo "Dir $HOST.$1$old not found, skip move."
        fi
    done
    if [ -z "$1" ]
    then
        if [ "$TEST" == "Y" ]
        then
            echo "cp -al $HOST $HOST.$FIRST"
        fi
        cp -al $HOST $HOST.$FIRST
    else
        if [ "$TEST" == "Y" ]
        then
            echo "mv -f $HOST.$2$MAXCT $HOST.$1$FIRST"
        fi
        mv -f $HOST.$2$MAXCT $HOST.$1$FIRST
    fi
}

# Számláló
# $1     Fájl neve
# return számláló értéke
cnt()
{
    if [ -f $1 ]
    then
        CNT=`cat $1`
    else
        CNT=$FIRST
    fi
    if [ $CNT -gt $MAXCT ]
    then
        echo "0" >$1
    else 
        expr $CNT + 1 >$1
    fi
    if [ "$TEST" == "Y" ]
    then
        echo "cnt $1; return $CNT" >>$LOG
    fi
    return $CNT
}

echo -n "Begin $HOST backup " >>$LOG
date >>$LOG

cnt $FACNT
CNT=$?
if [ $CNT -gt $MAXCT ]
then
    cnt $FBCNT
    CNT=$?
    if [ $CNT -gt $MAXCT ]
    then
    	roll B A
    fi
    roll A ""
fi
roll ""

if [ "$TEST" == "Y" ]
then
    echo "skyp sync"
    echo -n "DIR : "; ls -d $HOST*
    RESULT="DEBUG"
else
    ssh $HOST /usr/local/sbin/backup_prelude.sh >>$LOG 2>&1
    rsync --exclude-from $DATA/exclude-${HOST}.txt -a --delete-excluded --delete ${HOST}:/ $HOST
    RESULT=$?
    date >$HOST/BackupTimeStamp
fi

echo -n "End $HOST backup ($RESULT) " >>$LOG
date >>$LOG


