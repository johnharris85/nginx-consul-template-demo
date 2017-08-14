#!/bin/bash

echo "### Bootstrapping core components... ###"

######## VARIABLE SETUP ########

MACHINE_IP_LIST=$(docker-machine ls -f "{{.URL}}" | tr -d '/' | cut -d: -f2)
MACHINE_COUNT=$(wc -w <<< "$MACHINE_IP_LIST")

######## CONSUL SETUP ########

join_list=""

for i in $MACHINE_IP_LIST
do
  join_list+="-retry-join=$i "
done

CONSUL_IMAGE_VERSION=consul:0.9.2

eval $(docker-machine env -u)
docker pull $CONSUL_IMAGE_VERSION
docker save $CONSUL_IMAGE_VERSION > consul.tar

for i in $(seq 1 $MACHINE_COUNT)
do
  eval $(docker-machine env node$i)
  docker rm -f consul
  docker load --input consul.tar
  # TODO look at a config file for consul to expose UI properly to external but services to only local clients, removes -client option
  # TODO remove --net=host? Do we need to add anything else to make service registration work? Bridge net per host? Then switch to stack.yml?
  # TODO remove net=host? bridge net per host?
  docker run -d --name=consul --net=host $CONSUL_IMAGE_VERSION agent -server -ui -bootstrap-expect=3 -client=0.0.0.0 -bind='{{ GetInterfaceIP "eth1" }}' $join_list
done

rm consul.tar

######## REGISTRATOR SETUP ########

REGISTRATOR_IMAGE_VERSION=gliderlabs/registrator:master
CONSUL_ADDR=localhost:8500

eval $(docker-machine env -u)
docker pull $REGISTRATOR_IMAGE_VERSION
docker save $REGISTRATOR_IMAGE_VERSION > registrator.tar

for i in $(seq 1 $MACHINE_COUNT)
do
  eval $(docker-machine env node$i)
  docker rm -f registrator
  docker load --input registrator.tar
  # TODO new volume syntax
  # TODO remove net=host? bridge net per host?
  docker run -d --name=registrator --net=host --volume=/var/run/docker.sock:/tmp/docker.sock $REGISTRATOR_IMAGE_VERSION -explicit -ip $(docker-machine ip node$i) consul://$CONSUL_ADDR
done

rm registrator.tar

######## NGINX SETUP ########

NGINX_CONSUL_TEMPLATE_IMAGE_VERSION=johnharris85/nginx-consul-template:1

eval $(docker-machine env -u)
docker pull $NGINX_CONSUL_TEMPLATE_IMAGE_VERSION
docker save $NGINX_CONSUL_TEMPLATE_IMAGE_VERSION > nginx.tar

eval $(docker-machine env node1)
docker rm -f nginx
docker load --input nginx.tar
# TODO remove net=host? bridge net per host?
docker run -d --init --name=nginx --net=host $NGINX_CONSUL_TEMPLATE_IMAGE_VERSION

rm nginx.tar

######## APPLICATION SETUP ########

APP_IMAGE_VERSION=johnharris85/simple-hostname-reporter:2

eval $(docker-machine env -u)
docker pull $APP_IMAGE_VERSION
docker save $APP_IMAGE_VERSION > app.tar

for i in $(seq 1 $MACHINE_COUNT)
do
  eval $(docker-machine env node$i)
  docker rm -f hostname-reporter1
  docker load --input app.tar
  docker run -d --name=hostname-reporter1 -e SERVICE_NAME=app -p 5000:5000 $APP_IMAGE_VERSION 
done

rm app.tar

eval $(docker-machine env -u)

echo "### Completed bootstrapping core components... ###"

xdg-open http://$(docker-machine ip node1)/app
xdg-open http://$(docker-machine ip node1):8500/ui