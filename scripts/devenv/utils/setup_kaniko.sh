#!/bin/sh

#############################################
# Setup kaniko in the target cluster.       #
#############################################
# This script setup the cluster that can build not with the dev container
# but with kaniko in the cluster.
#
# This scripts does ...
#   1. Create name space for kaniko.
#      You shoud specify build.cluster.namespace.
#   2. Create the secret so the kaniko in the cluster can push/pull
#      to/from the private registry.
#      You should specify build.cluster.dockerConfig.secret.
# 
# For example:
# sh setup_kaniko.sh -n kaniko -u use_name -p password_or_pat
SCRIPTDIR=$( cd "$( dirname "$0" )" && pwd )

usage() {
    echo "Usage: $1 [-n namespace] [-c secret_name] -s registry_server -u registry_user -p password" 1>&2
    echo "Parameters:" 1>&2
    echo "  -n namespace: Namespace in which kaniko runs." 1>&2
    echo "  -s registry_server: Registry server that kaniko will push/pull." 1>&2
    echo "  -u registry_user: Username of registry server that kaniko will push/pull." 1>&2
    echo "  -p password: Password of registry server that kaniko will push/pull." 1>&2
    echo "  -c secret_name: The name of secret that holds user/password." 1>&2
}

while [ $# -gt 0 ]
do
    case "$1" in
    "-n") shift; NS=$1 ;;
    "-s") shift; SRV=$1 ;;
    "-u") shift; USR=$1 ;;
    "-p") shift; PWD=$1 ;;
    "-c") shift; SEC=$1 ;;
    *)  usage "$0"; exit 1 ;;
    esac
    if [ $# -gt 0 ] ; then
        shift
    fi
done

if [ -z "${SRV}" ] || [ -z "${USR}" ] || [ -z "${PWD}" ] ; then
    usage "$0"
    exit 1
fi

echo "##############################################"
echo "# Creating namespace                         #"
echo "##############################################"
NAMESPACE=kaniko
if [ -n "${NS}" ] ; then
    NAMESPACE="${NS}"
fi

SECRET=registrykey
if [ -n "${SEC}" ] ; then
    SECRET="${SEC}"
fi

echo -n "Creating namespace ... "
kubectl create ns "${NAMESPACE}"
echo "Done."
echo -n "Creating secret ... "
kubectl -n "${NAMESPACE}" delete secret "${SECRET}" >/dev/null 2>&1
AUTH=$(echo -n "${USR}:${PWD}" | base64 -w 0)
CONFIG='{"auths": {"'${SRV}'": {"auth": "'${AUTH}'"}}}'
kubectl -n "${NAMESPACE}" create secret generic "${SECRET}" --from-literal=config.json="${CONFIG}"
echo "Done. Auth=${CONFIG}"
echo "Please remember setting auth in ~/.docker/config.json even if you build with kaniko."
