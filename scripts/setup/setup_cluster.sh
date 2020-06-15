#!/bin/sh
set -e

####################################
# Microk8s for develop setup       #
####################################
SCRIPTDIR=$( cd "$( dirname "$0" )" && pwd )
NAME=""
ISTIO=""

while [ $# -gt 0 ]
do
    case "$1" in
    "-n") shift; NAME=$1 ;;
    "--with-istio") ISTIO=1 ;;
    *)  echo "Usage: $0 [-n vmname] [--with-istio]"; exit 1 ;;
    esac
    shift
done

VMNAME=microk8s-dev-vm
if [ ! -z "${NAME}" ] ; then
    VMNAME=${NAME}
fi

echo "##############################################"
echo "# Creating multipass vm and install microk8s #"
echo "##############################################"
echo "Creating VM: ${VMNAME}"

multipass launch --mem 4G --disk 40G --name ${VMNAME}

mkdir -p ${SCRIPTDIR}/clusterinfo
multipass list | grep ${VMNAME} > ${SCRIPTDIR}/clusterinfo/hostname
HOST_IP=`awk '{print $3}' ${SCRIPTDIR}/clusterinfo/hostname`

multipass copy-files ${SCRIPTDIR}/shell/install_microk8s.sh ${VMNAME}:/tmp
multipass exec ${VMNAME} -- sh /tmp/install_microk8s.sh ${HOST_IP}

multipass exec ${VMNAME} -- sudo /snap/bin/microk8s.kubectl config view --raw | \
    sed -e "s/127.0.0.1/${HOST_IP}/" > ${SCRIPTDIR}/clusterinfo/config

echo "##############################################"
echo "# Creating develop environment               #"
echo "##############################################"

VSDIR=${SCRIPTDIR}/../../.vscode
echo "Generating launch.json ... \c"
sed -e "s/%%SKAFFOLD_DEFAULT_REPO%%/${HOST_IP}:32000/" ${VSDIR}/launch_tmpl.json \
        > ${VSDIR}/launch.json
echo "Done."

echo "Add docker daemon config below and restart docker."
echo "======================================================"
echo '{"insecure-registries" : [' "\"${HOST_IP}:32000\"" ']}'
echo "======================================================"

if [ ${ISTIO} -eq 1 ] ; then
    echo ""
    echo "##############################################"
    echo "# Install Istio                              #"
    echo "##############################################"
    multipass copy-files ${SCRIPTDIR}/shell/install_istio.sh ${VMNAME}:/tmp
    multipass copy-files ${SCRIPTDIR}/shell/istio.yaml ${VMNAME}:/tmp
    multipass copy-files ${SCRIPTDIR}/shell/k8s/k8s-ingress.yaml ${VMNAME}:/tmp
    multipass copy-files ${SCRIPTDIR}/shell/k8s/k8s-kiali-ingress_tpl.yaml ${VMNAME}:/tmp
    multipass exec ${VMNAME} -- sh /tmp/install_istio.sh ${HOST_IP}
fi

echo "Done."
