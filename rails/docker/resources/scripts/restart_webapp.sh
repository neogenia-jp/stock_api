#!/bin/bash

echo '--- RESTART APP START ---'

#---------------------------------------------------------------------
# rails 再起動
$SCRIPTS_ROOT_DIR/restart_webapp_rails.sh $RAILS_ROOT_DIR/tmp/puma.pid 30 1
if [ $? -ne 0 ]; then
  exit 1
fi

if [ "$ENABLE_DELAYED_JOB" = "1" ]; then
  #---------------------------------------------------------------------
  # delayed_job 再起動
  $SCRIPTS_ROOT_DIR/restart_webapp_delayed_job.sh $RAILS_ROOT_DIR/tmp/pids/delayed_job.pid 60 1
  if [ $? -ne 0 ]; then
    exit 2
  fi
fi

echo '--- RESTART APP FINISHED ---'

