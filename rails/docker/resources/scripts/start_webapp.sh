#!/bin/bash

cd $RAILS_ROOT_DIR

SCRIPT_DIR=$(cd $(dirname $0) && pwd)
$SCRIPT_DIR/check_rails_dir_permission.sh

# change vendor permission
chown www-data:www-data vendor
chown www-data:www-data node_modules

# ディレクトリの権限チェックと自動作成
function check_dir() {
  if [ -d $1 ]; then
    if su www-data -c "[ ! -w $1 ]"; then
      echo "##### ERROR ##### directory $(pwd)/$1 is not writable"
      exit 2
    fi
  else
    su www-data -c "mkdir $1"
    if [ $? -ne 0 ]; then
      echo "##### ERROR ##### failed mkdir $(pwd)/$1"
      exit 3
    fi
  fi
}

# Check "tmp" directory's permission.
check_dir 'tmp'
check_dir 'tmp/sockets'  # /var/scripts/start_debug_webapp.sh で手動起動する際に必要
check_dir 'tmp/pids'     # /var/scripts/start_debug_webapp.sh で手動起動する際に必要

# Check "log" directory's permission.
check_dir 'log'

if [ "$1" = "manual" ] ; then
  # 開発時用に手動でrailsを起動、終了出来るようにmonitを起動しないモード。
  #
  # railsを起動する場合はホストから
  #  docker exec -it stock_api_rails bash
  # でこのコンテナに入り、
  # コンソールデバッグ：
  #  $SCRIPTS_ROOT_DIR/start_debug_webapp.sh
  #
  # リモートデバッグ用起動：
  #  $SCRIPTS_ROOT_DIR/start_remote_debug_webapp.sh
  #
  # で起動する
  echo '***** MANUAL MODE *****'
  echo "Prease exec below command on host:"
  echo '  docker exec -ti stock_api_rails bash'
  exec tail -f /dev/null
  exit
fi

chmod 777 public public/packs db

echo "start yarn install"
su www-data -c 'yarn install --check-files'
if [ $? -ne 0 ]; then
  echo "##### ERROR ##### failed yarn install"
  exit 5
fi

if [ "$1" = "remote_debug" ] ; then
  export BUNDLE_GEMFILE=Gemfile.remote_debug
fi

echo "start bundle install $BUNDLE_GEMFILE"
su www-data -c 'bundle install -j$(nproc)'
if [ $? -ne 0 ]; then
  echo "##### ERROR ##### failed bundle install"
  exit 4
fi

if [ "$RAILS_ENV" = "production" ]; then
  echo "recreate credentials file"
  su www-data -c 'EDITOR=vim bin/rails credentials:edit'

  echo "start assets:precompile"
  su www-data -c 'bin/rails assets:precompile'
  if [ $? -ne 0 ]; then
    echo "##### ERROR ##### failed assets:precompile"
    exit 6
  fi

  echo "start db:migrate"
  su www-data -c 'bin/rails db:migrate'
  if [ $? -ne 0 ]; then
    echo "##### ERROR ##### failed db:migrate"
    exit 7
  fi
fi

# PIDファイルを削除
rm tmp/puma.pid 2>/dev/null

# monitを利用する、通常起動モード
ENABLED_PATH=/etc/monit/conf-enabled
AVAILABLE_PATH=/etc/monit/conf-available
[[ -f $ENABLED_PATH/delayed_job ]] && unlink $ENABLED_PATH/delayed_job
[[ -f $RAILS_ROOT_DIR/tmp/pids/delayed_job.pid ]] && rm $RAILS_ROOT_DIR/tmp/pids/delayed_job.pid
if [ "$ENABLE_DELAYED_JOB" = "1" ]; then
  echo '-- enable delayed_job.'
  ln -s $AVAILABLE_PATH/delayed_job $ENABLED_PATH/delayed_job
fi

if [ "$1" = "remote_debug" ] ; then
  echo > /tmp/start_rails_app.log
  chmod 666 /tmp/start_rails_app.log
  /usr/bin/monit -c /etc/monit/monitrc
  echo '***** REMOTE DEBUG MODE *****'
  tail -f /tmp/start_rails_app.log
else
  echo '----- START APP via MONIT -----'
  #/usr/bin/monit -vv -I -c /etc/monit/monitrc  # for debug
  /usr/bin/monit -I -c /etc/monit/monitrc
fi
