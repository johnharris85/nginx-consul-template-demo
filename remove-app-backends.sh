#!/bin/bash

######## VARIABLE SETUP ########

MACHINE_IP_LIST=$(docker-machine ls -f "{{.URL}}" | tr -d '/' | cut -d: -f2)
MACHINE_COUNT=$(wc -w <<< "$MACHINE_IP_LIST")

######## REMOVE BACKENDS ########

for i in $(seq 1 $MACHINE_COUNT)
do
  eval $(docker-machine env node$i)
  docker rm -f hostname-reporter{2,3}
done

eval $(docker-machine env -u)