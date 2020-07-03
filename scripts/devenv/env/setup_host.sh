#!/bin/sh

# Create namespaces...
sudo /snap/bin/microk8s.kubectl create namespace mesh
sudo /snap/bin/microk8s.kubectl label namespace mesh istio-injection=enabled

