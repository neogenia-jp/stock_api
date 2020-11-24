#!/bin/bash

if [ "$DEBUG" = "remote_debug" ] ; then
  # Railsアプリケーションをリモートデバッグするためのモード

  $SCRIPTS_ROOT_DIR/start_remote_debug_webapp.sh | tee /tmp/start_rails_app.log 2>&1

else

  echo '----- START PUMA -----'

  cd $RAILS_ROOT_DIR
  exec bundle exec puma \
    --bind tcp://0.0.0.0:$RAILS_PORT \
    --daemon
fi
