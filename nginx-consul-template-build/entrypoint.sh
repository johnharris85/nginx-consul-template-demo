#!/bin/sh

consul-template -log-level info -consul-addr ${CONSUL_ADDRESS} -config "/etc/consul-template-configs"