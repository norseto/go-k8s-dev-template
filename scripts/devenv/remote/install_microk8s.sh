#!/bin/sh

# Get external IP address.
EXTERNAL_IP=""
if [ $# -gt 0 ] ; then
	EXTERNAL_IP=$1
fi

# K8s Version. Currently, EKS supports K8s version 1.14-16
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

# Under rabac environment, create configmap for ingress controller.
# 1.14 or earlier
#sudo /snap/bin/microk8s.kubectl -n default create cm ingress-controller-leader-nginx
sudo /snap/bin/microk8s.kubectl -n ingress create cm ingress-controller-leader-nginx

sudo usermod -a -G microk8s $(whoami)
sudo snap alias microk8s.kubectl kubectl

# Make symbolic link so that skaffold can find kubectl
sudo ln -s /var/lib/snapd/snap/bin/microk8s.kubectl /usr/bin/kubectl
