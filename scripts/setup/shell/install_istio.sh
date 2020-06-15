#!/bin/sh
# Get external IP address.
EXTERNAL_IP=""
if [ $# -gt 0 ] ; then
	EXTERNAL_IP=$1
fi

####################################
# Istio downloader                 #
####################################
SCRIPTDIR=$( cd "$( dirname "$0" )" && pwd )
KUBECTL=/snap/bin/microk8s.kubectl

export ISTIO_VERSION=1.6.2
if [ ! -x ${SCRIPTDIR}/istio-${ISTIO_VERSION}/bin/istioctl ] ; then
	(cd ${SCRIPTDIR} && curl -L https://istio.io/downloadIstio | sh -)
fi
sudo cp -p ${SCRIPTDIR}/istio-${ISTIO_VERSION}/bin/istioctl /usr/bin
sudo ${KUBECTL} config view --raw > /tmp/istioconf

${KUBECTL} create ns istio-system
cat <<_EOM |
apiVersion: v1
kind: Secret
metadata:
  name: kiali
type: Opaque
data:
  username: YWRtaW4=
  passphrase: a2lhbGk=
_EOM
${KUBECTL} -n istio-system apply -f -
${KUBECTL} label namespace default istio-injection=enabled

export KUBECONFIG=/tmp/istioconf
istioctl install -f ${SCRIPTDIR}/istio.yaml

${KUBECTL} apply -f ${SCRIPTDIR}/k8s-ingress.yaml

if [ ! -z "${EXTERNAL_IP}" ] ; then
	IP_NIP=`echo ${EXTERNAL_IP} | sed -e 's/\./-/g'`
	sed -e "s/%%EXTERNAL_IP%%/${IP_NIP}/" ${SCRIPTDIR}/k8s-kiali-ingress_tpl.yaml | ${KUBECTL} apply -f -
fi
