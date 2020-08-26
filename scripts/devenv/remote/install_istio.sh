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

#export ISTIO_VERSION=1.6.8
#ISTIO_MANIFEST=istio_16.yaml

export ISTIO_VERSION=1.7.0
ISTIO_MANIFEST=istio_17.yaml

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

export KUBECONFIG=/tmp/istioconf
istioctl install -f ${SCRIPTDIR}/${ISTIO_MANIFEST}

${KUBECTL} apply -f ${SCRIPTDIR}/k8s-ingress.yaml

if [ ! -z "${EXTERNAL_IP}" ] ; then
	IP_NIP=`echo ${EXTERNAL_IP} | sed -e 's/\./-/g'`
	sed -e "s/%%EXTERNAL_IP%%/${IP_NIP}/" ${SCRIPTDIR}/k8s-kiali-ingress_tpl.yaml | ${KUBECTL} apply -f -
fi
