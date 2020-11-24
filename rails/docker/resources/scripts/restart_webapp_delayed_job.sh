#!/bin/bash

if [ "$ENABLE_DELAYED_JOB" != "1" ]; then
  echo 'delayed_job is disabled. nothing to do.'
  exit 0
fi

#---------------------------------------------------------------------
# delayed_job 再起動

cd $RAILS_ROOT_DIR

if [ "$1" = "" ]
then
    echo "PID_FILEを指定して下さい"
fi
DELAYED_JOB_PID_FILE=$1

if [ "$2" = "" ]
then
    echo "WAIT_LIMITを指定して下さい"
fi
WAIT_LIMIT=$2

if [ "$3" = "" ]
then
    echo "SLEEP_TIMEを指定して下さい"
fi
SLEEP_TIME=$3

DELAYED_JOB_PID_FILE=tmp/pids/delayed_job.pid
if [ ! -f $DELAYED_JOB_PID_FILE ]; then
  echo "delayed_job's pid file not found."
  exit 1
fi

OLD_DELAYED_JOB=$(cat $DELAYED_JOB_PID_FILE)
ps $OLD_DELAYED_JOB > /dev/null
if [ $? != '0'  ]; then
  echo "delayed's process not found. pid:$OLD_DELAYED_JOB"
  exit 2
fi

echo "restart delayed_job..."

#monit -I restart delayed_job
bin/delayed_job stop && bin/delayed_job start

STAT=$?
if [ $STAT != 0 ]; then
  echo "restart delayed_job fail. code: ${STAT}"
  exit 4
fi

COUNT=0
WAIT_END=0
while [ $WAIT_END -eq 0 ]
do
  sleep $SLEEP_TIME
  COUNT=$(( COUNT + 1 ))

  if [ -f $DELAYED_JOB_PID_FILE ]; then
    if [ "$(cat $DELAYED_JOB_PID_FILE)" != "$OLD_DELAYED_JOB" ]; then
      # pidファイルが存在して、その中のPIDが再起動前と変わっていれば再起動完了とみなす
      WAIT_END=1
    fi
  fi

  echo " - waiting for delayed_job restarted ...COUNT: $COUNT"
  if [ $COUNT -ge $WAIT_LIMIT ]; then
    echo "### ERROR ### failed delayed_job restart"
    exit 4
  fi
done
echo "delayed_job restarted."

