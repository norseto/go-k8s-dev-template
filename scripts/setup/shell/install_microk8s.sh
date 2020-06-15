#!/bin/sh

# Get external IP address.
EXTERNAL_IP=""
if [ $# -gt 0 ] ; then
	EXTERNAL_IP=$1
fi

# K8s Version. Currently, EKS supports K8s version 1.12-14
# https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
K8SVERSION=1.16

# Install and configure microk8s
sudo snap install microk8s --classic --channel=${K8SVERSION}/stable || exit 1
sudo /snap/bin/microk8s.status --wait-ready >/dev/null 2>&1

CONFDIR=/var/snap/microk8s/current/args
CONFFILE=${CONFDIR}/containerd-template.toml
REGENDPOINT="${EXTERNAL_IP}:32000"
if [ ! -z "${EXTERNAL_IP}" ] ; then
	echo "Configuring insercure registry for internal containerd ... \c"
	sudo cp -p ${CONFFILE} ${CONFDIR}/containerd-template.toml_org
	echo "" | sudo tee -a ${CONFFILE} > /dev/null
	echo '[plugins.cri.registry.mirrors."'${REGENDPOINT}'"]' | sudo tee -a ${CONFFILE} > /dev/null
	echo '  endpoint = ["http://'${REGENDPOINT}'"]' | sudo tee -a ${CONFFILE} > /dev/null
	echo "Done."
	echo "Restarting microk8s..."
	sudo /snap/bin/microk8s.stop
	sudo /snap/bin/microk8s.start
fi

ADDONS="rbac dns metrics-server storage ingress registry"
for addon in ${ADDONS} ; do
	echo "Enabling ${addon}. If you faced an error, re-run this script."
	sudo /snap/bin/microk8s.status --wait-ready >/dev/null 2>&1
	sudo /snap/bin/microk8s.enable ${addon} || exit 1
done
sudo /snap/bin/microk8s.status --wait-ready

sudo usermod -a -G microk8s $(whoami)
sudo snap alias microk8s.kubectl kubectl

# Under rabac environment create configmap for ingress controller.
# 1.14 or earlier
#microk8s.kubectl -n default create cm ingress-controller-leader-nginx
/snap/bin/microk8s.kubectl -n ingress create cm ingress-controller-leader-nginx

# Make symbolic link so that skaffold can find kubectl
sudo ln -s /var/lib/snapd/snap/bin/microk8s.kubectl /usr/bin/kubectl
# sudo snap alias microk8s.helm helm

# Install and configure docker
# sudo addgroup --system docker
# sudo adduser $USER docker
# sudo apt-get update
# sudo apt-get install -y make docker.io

# # Install kustomize
# KUSTOMIZE_VERSION=v3.5.4
# KUSTOMIZE_BIN=kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz
# wget https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/${KUSTOMIZE_BIN}
# tar xvzf ${KUSTOMIZE_BIN}
# sudo mv kustomize /usr/bin

# # Install skaffold
# SKAFFOLD_VERSION=v1.2.0
# SKAFFOLD_BIN=skaffold-linux-amd64
# wget https://github.com/GoogleContainerTools/skaffold/releases/download/${SKAFFOLD_VERSION}/skaffold-linux-amd64
# chmod +x ${SKAFFOLD_BIN}
# sudo mv ${SKAFFOLD_BIN} /usr/bin/skaffold

# rm ${KUSTOMIZE_BIN}

# # Install kubectx/kubens
# KUBECTX_VERSION=v0.8.0
# curl -sLO https://raw.githubusercontent.com/ahmetb/kubectx/${KUBECTX_VERSION}/kubectx
# chmod +x kubectx
# curl -sLO https://raw.githubusercontent.com/ahmetb/kubectx/${KUBECTX_VERSION}/kubens
# chmod +x kubens
# sudo mv kubectx kubens /usr/bin

# # Install argo-rollouts plugin
# curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
# sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/bin/kubectl-argo-rollouts
# sudo chmod +x /usr/bin/kubectl-argo-rollouts

# # Install apache2-utils for argo passwd
# sudo apt-get install -y apache2-utils

# echo "Exit and log in again now."