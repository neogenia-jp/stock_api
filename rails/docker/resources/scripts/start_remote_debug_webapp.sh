#!/bin/bash
$SCRIPTS_ROOT_DIR/stop_rails_app.sh > /dev/null

echo '--'
echo '-- Starting rdebug-ide...'
echo '-- Please connect from host IDE'
echo '-- https://qiita.com/takc923/items/d6aa69dfc96f5e24871e'
echo '--'

export DEBUG=remote_debug
export BUNDLE_GEMFILE=Gemfile.remote_debug
export IDE_PROCESS_DISPATCHER=host.docker.internal:26163
export HOME=$RAILS_ROOT_DIR
cd $HOME
bundle exec rdebug-ide --host 0.0.0.0 --port 1235 --rubymine-protocol-extensions -- bin/rails s -b 0.0.0.0 -p $RAILS_PORT

