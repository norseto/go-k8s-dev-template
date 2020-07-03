#!/bin/sh
set -e

####################################
# Microk8s for develop setup       #
####################################
SCRIPTDIR=$( cd "$( dirname "$0" )" && pwd )
ENVDIR="${SCRIPTDIR}/env"
NAME=""
ISTIO=0
DISKSIZE="40G"
MEMSIZE="4G"

if [ -f "${ENVDIR}/env.sh" ] ; then
    . "${ENVDIR}/env.sh"
fi

while [ $# -gt 0 ]
do
    case "$1" in
    "-n") shift; NAME=$1 ;;
    "--with-istio") ISTIO=1 ;;
    *)  echo "Usage: $0 [-n vmname] [--with-istio]"; exit 1 ;;
    esac
    if [ $# -gt 0 ] ; then
        shift
    fi
done

VMNAME=k8s
if [ -n "${NAME}" ] ; then
    VMNAME=${NAME}
fi

echo "##############################################"
echo "# Creating multipass vm and install microk8s #"
echo "##############################################"
echo "Creating VM: ${VMNAME}"

multipass launch --mem "${MEMSIZE}" --disk "${DISKSIZE}" --name "${VMNAME}"

mkdir -p "${SCRIPTDIR}/clusterinfo"
multipass list | grep "${VMNAME}" > "${SCRIPTDIR}/clusterinfo/hostname"
HOST_IP=$(awk '{print $3}' "${SCRIPTDIR}/clusterinfo/hostname")

multipass copy-files "${SCRIPTDIR}/remote/install_microk8s.sh" "${VMNAME}:/tmp"
multipass exec "${VMNAME}" -- sh /tmp/install_microk8s.sh "${HOST_IP}"

multipass exec "${VMNAME}" -- sudo /snap/bin/microk8s.kubectl config view --raw | \
    sed -e "s/127.0.0.1/${HOST_IP}/" > "${SCRIPTDIR}/clusterinfo/config"

echo "Add docker daemon config below and restart docker if you need."
echo "======================================================"
echo '{"insecure-registries" : [' "\"${HOST_IP}:32000\"" ']}'
echo "======================================================"

if [ ${ISTIO} -eq 1 ] ; then
    echo ""
    echo "##############################################"
    echo "# Install Istio                              #"
    echo "##############################################"
    multipass copy-files "${SCRIPTDIR}/remote/install_istio.sh" "${VMNAME}:/tmp"
    multipass copy-files "${SCRIPTDIR}/remote/istio.yaml" "${VMNAME}:/tmp"
    multipass copy-files "${SCRIPTDIR}/remote/k8s/k8s-ingress.yaml" "${VMNAME}:/tmp"
    multipass copy-files "${SCRIPTDIR}/remote/k8s/k8s-kiali-ingress_tpl.yaml" "${VMNAME}:/tmp"
    multipass exec "${VMNAME}" -- sh /tmp/install_istio.sh "${HOST_IP}"
fi

echo ""
echo "##############################################"
echo "# Running Setup Script(remote/setup_host.sh) #"
echo "##############################################"
multipass copy-files "${ENVDIR}/setup_host.sh" "${VMNAME}:/tmp/setup_host.sh"
multipass exec "${VMNAME}" -- mkdir -p /tmp/initial-data
for file in "${ENVDIR}"/data/* ; do
    if [ -f "${file}" ] ; then
        basefile=$(basename "${file}")
        multipass copy-files "${file}" "${VMNAME}:/tmp/initial-data/${basefile}"
    fi
done
multipass exec "${VMNAME}" -- sh /tmp/setup_host.sh "${HOST_IP}" "${VMNAME}"

echo ""
echo "##############################################"
echo "# Running Local Setup(env/setup_devenv.sh) #"
echo "##############################################"
sh ${ENVDIR}/setup_devenv.sh "${HOST_IP}" "${VMNAME}"

echo "Done."
