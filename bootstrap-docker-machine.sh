#!/bin/bash

# Sample run command:
# ./bootstrap-docker-machine.sh 3

for i in $(seq 1 $1)
do
  docker-machine create -d virtualbox node$i
done