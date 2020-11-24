#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0) && pwd)
source ${SCRIPT_DIR}/common.sh

YML1=${YML_DIR}/docker-compose-webapp.yml

if [ "$RAILS_APP_ENV" != "production" ]; then
  echo '!!!!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!!!!'
  echo ' $RAILS_ENV is not set to "production" !'
fi

docker-compose -f $YML1 $*

