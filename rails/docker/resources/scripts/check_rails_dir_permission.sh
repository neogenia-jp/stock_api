#!/bin/bash

cd $RAILS_ROOT_DIR

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

# ディレクトリの権限をチェックし、権限がなければ書き込み権限を付与
function make_writable() {
  echo "Check \"$1\" directory's permission."
  check_dir $1
  ret=$?
  if [ "$ret" -eq 2 ]; then
    chmod 755 $1
    echo "-- It was NOT writable, then it has been made writable."
  else
    echo "-- OK."
  fi
}

make_writable 'log'
make_writable 'config'

if [ ! -d tmp ]; then
  echo 'start `bin/rails tmp:create`'
  su www-data -c 'bin/rails tmp:create'
fi
