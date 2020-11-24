#!/bin/bash

#---------------------------------------------------------------------
# rails 再起動

cd $RAILS_ROOT_DIR

if [ "$1" = "" ]
then
  echo "##### ERROR ##### PID_FILEを指定して下さい"
  exit 1
fi
PUMA_PID_FILE=$1

if [ "$2" = "" ]
then
  echo "##### ERROR ##### WAIT_LIMITを指定して下さい"
  exit 2
fi
WAIT_LIMIT=$2

if [ "$3" = "" ]
then
  echo "##### ERROR ##### SLEEP_TIMEを指定して下さい"
  exit 3
fi
SLEEP_TIME=$3

if [ ! -f $PUMA_PID_FILE ]; then
  echo "##### ERROR ##### puma's pid file not found."
  exit 4
fi

PUMA_PID=$(cat $PUMA_PID_FILE)
ps $PUMA_PID > /dev/null
if [ $? != '0'  ]; then
  echo "##### ERROR ##### puma's process not found. pid:$PUMA_PID"
  exit 5
fi

if [ "$RAILS_ENV" = "production" ]; then
  chmod a+w node_modules/.yarn-integrity
  chmod a+w -R tmp node_modules
  chmod 777 public public/packs db
fi

echo "___1__start bundle install"
su www-data -c 'bundle install -j$(nproc)'
if [ $? -ne 0 ]; then
  echo "##### ERROR ##### failed bundle install"
  exit 6
fi

if [ "$RAILS_ENV" = "production" ]; then
  echo "start assets:precompile"
  su www-data -c 'bin/rails assets:precompile'
  if [ $? -ne 0 ]; then
    echo "##### ERROR ##### failed assets:precompile"
    exit 8
  fi

  echo "start db:migrate"
  su www-data -c 'bin/rails db:migrate'
  if [ $? -ne 0 ]; then
    echo "##### ERROR ##### failed db:migrate"
    exit 9
  fi
fi

echo "restart rails..."
kill -SIGUSR2 $PUMA_PID
STAT=$?
if [ $STAT != 0 ]; then
  echo "##### ERROR ##### restart rails fail. code: ${STAT}"
  exit 10
fi

COUNT=0
WAIT_END=0
while [ $WAIT_END -eq 0 ]
do
  sleep $SLEEP_TIME
  COUNT=$(( COUNT + 1 ))

  if [ -f $PUMA_PID_FILE ]; then
    if [ "$(cat $PUMA_PID_FILE)" != "$PUMA_PID" ]; then
      # pidファイルが存在して、その中のPIDが再起動前と変わっていれば再起動完了とみなす
      WAIT_END=1
    fi
  fi

  echo " - waiting for rails restarted ...COUNT: $COUNT"
  if [ $COUNT -ge $WAIT_LIMIT ]; then
    echo "### ERROR ### failed rails restart"
    exit 11
  fi
done

echo "rails restarted."

