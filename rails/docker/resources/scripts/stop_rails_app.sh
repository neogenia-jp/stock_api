#!/bin/bash

echo '--- STOP RAILS START ---'

cd $RAILS_ROOT_DIR

if [ ! -f tmp/puma.pid ]; then
  echo "puma's pid file not found."
  exit 1
fi

PUMA_PID=$(cat tmp/puma.pid)
ps $PUMA_PID > /dev/null
if [ $? != '0'  ]; then
  echo "puma's process not found. pid:$PUMA_PID"
  exit 2
fi

kill -QUIT $PUMA_PID
STAT=$?
if [ $STAT != 0 ]; then
  echo "stop fail. code: ${STAT}"
  exit 3
fi

echo '--- STOP RAILS END ---'
