#!/bin/bash
$SCRIPTS_ROOT_DIR/stop_rails_app.sh > /dev/null

export DEBUG=manual
export HOME=$RAILS_ROOT_DIR
cd $HOME
su www-data -c 'yarn install --check-files' \
 && su www-data -c 'bundle install' \
 && su www-data -c "bundle exec puma --bind tcp://0.0.0.0:$RAILS_PORT"

