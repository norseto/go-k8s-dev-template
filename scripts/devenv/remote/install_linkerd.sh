#!/bin/sh
# Get external IP address.
EXTERNAL_IP=""
if [ $# -gt 0 ] ; then
	EXTERNAL_IP=$1
fi

####################################
# Download Linkerd                 #
####################################
SCRIPTDIR=$( cd "$( dirname "$0" )" && pwd )
KUBECTL=/snap/bin/microk8s.kubectl
export KUBECONFIG=/tmp/config
sudo ${KUBECTL} config view --raw > ${KUBECONFIG}

curl -sL https://run.linkerd.io/install | sh
export PATH=$PATH:$HOME/.linkerd2/bin
linkerd install | kubectl apply -f -
linkerd check

if [ ! -z "${EXTERNAL_IP}" ] ; then
	IP_NIP=`echo ${EXTERNAL_IP} | sed -e 's/\./-/g'`
	sed -e "s/%%EXTERNAL_IP%%/${IP_NIP}/" ${SCRIPTDIR}/k8s-linkerd-ingress_tpl.yaml | ${KUBECTL} apply -f -
fi
