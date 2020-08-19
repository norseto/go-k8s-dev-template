#!/bin/sh
# Get external IP address.
EXTERNAL_IP=""
if [ $# -gt 0 ] ; then
	EXTERNAL_IP=$1
fi

####################################
# Enable HELM                      #
####################################
SCRIPTDIR=$( cd "$( dirname "$0" )" && pwd )
KUBECTL="/snap/bin/microk8s.kubectl"
HELM="/snap/bin/microk8s.helm"

# export HELM_VERSION=2.14.0
# #export HELM_VERSION=3.3.0

# curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > /tmp/get_helm.sh
# chmod 700 /tmp/get_helm.sh
# /tmp/get_helm.sh

sudo /snap/bin/microk8s.enable helm

sudo snap alias microk8s.helm helm

# Make symbolic link so that skaffold can find kubectl
sudo ln -s /var/lib/snapd/snap/bin/microk8s.helm /usr/bin/helm

export KUBECONFIG=/tmp/istioconf
sudo ${KUBECTL} config view --raw > ${KUBECONFIG}
${KUBECTL} -n kube-system create sa tiller
${KUBECTL} create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
${HELM} init --service-account tiller
