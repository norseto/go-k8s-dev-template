#!/bin/sh

NAMESPACE=mesh

# Create namespaces...
sudo /snap/bin/microk8s.kubectl create namespace ${NAMESPACE}
sudo /snap/bin/microk8s.kubectl label namespace ${NAMESPACE} istio-injection=enabled
sudo /snap/bin/microk8s.kubectl annotate ns/${NAMESPACE} linkerd.io/inject=enabled
