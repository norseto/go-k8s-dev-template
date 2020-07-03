# Remote directory
This directory contains resources that will be launch in VM during setup.

## Files
- install_microk8s.sh : Microk8s installation script.
- install_istio.sh : Istio download/installation script.
- istio.yaml : Istio configuration YAML.
- k8s/k8s-ingress.yaml : Ingress configuration that proxies to istio-gateway.
- k8s/k8s-kiali-ingress_tpl.yaml : Template file for ingress configuration that proxies to kiali.