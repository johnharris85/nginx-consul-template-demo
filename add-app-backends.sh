#!/bin/bash

######## VARIABLE SETUP ########

MACHINE_IP_LIST=$(docker-machine ls -f "{{.URL}}" | tr -d '/' | cut -d: -f2)
MACHINE_COUNT=$(wc -w <<< "$MACHINE_IP_LIST")

######## ADD BACKENDS ########

APP_IMAGE_VERSION=johnharris85/simple-hostname-reporter:2

for i in $(seq 1 $MACHINE_COUNT)
do
  eval $(docker-machine env node$i)
  docker run -d --name=hostname-reporter2 -e SERVICE_NAME=app -p 5001:5000 $APP_IMAGE_VERSION
  docker run -d --name=hostname-reporter3 -e SERVICE_NAME=app -p 5002:5000 $APP_IMAGE_VERSION
done

eval $(docker-machine env -u)