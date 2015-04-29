#!/bin/bash

echo "-> removing openshift.local.* directories..."
sudo rm -rf openshift.local.*

echo "-> stopping all k8s docker containers..."
docker ps | awk '{ print $NF " " $1 }' | grep ^k8s_ | awk '{print $2}' |  xargs -l -r docker stop
