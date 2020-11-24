#!/bin/bash

SCRIPT_DIR=${SCRIPT_DIR:-$(cd $(dirname $0) && pwd)}

MKCERT_TEMP=/tmp/mkcert.tmp

mkcert -install >$MKCERT_TEMP 2>&1

if [ "$?" != "0" ]; then
  cat $MKCERT_TEMP
  rm $MKCERT_TEMP
  exit 1
fi

rm $MKCERT_TEMP

cd $SCRIPT_DIR/mnt

mkcert -key-file key.pem -cert-file cert.pem localhost $*

