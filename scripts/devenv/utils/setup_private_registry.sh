#!/bin/sh

#############################################
# Setup external private image registry     #
#############################################
# This scripts does ...
#   1. Update launch.json to use external private registry.
#   2. Create the secret so the cluster can pull from the private registry.
#   3. Bind Service Account's imagePullSecrets to the secret above.
# 
# For example: Use GitLab private registry.
# sh setup_private_registry.sh -r registry.gitlab.com/group/project/repo \
#     -s registry.gitlab.com -u use_name -p password_or_pat
UTL_SCRIPTDIR=$( cd "$( dirname "$0" )" && pwd )
SCRIPTDIR="${UTL_SCRIPTDIR}/.."

usage() {
    echo "Usage: $1 [-r default_repo] [[-n namespace] -s registry_server -u registry_user -p password [-c secret_name]]" 1>&2
    echo "Parameters:" 1>&2
    echo "  -r default_repo: Default repository name that will be updated into launch.json." 1>&2
    echo "  -n namespace: Namespace of the target ServiceAccount." 1>&2
    echo "  -s registry_server: Registry server that skaffold will push/pull." 1>&2
    echo "  -u registry_user: Username of registry server that skaffold will push/pull." 1>&2
    echo "  -p password: Password of registry server that skaffold will push/pull." 1>&2
    echo "  -c secret_name: The name of secret that holds user/password." 1>&2
}

while [ $# -gt 0 ]
do
    case "$1" in
    "-n") shift; NS=$1 ;;
    "-r") shift; REPO=$1 ;;
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

sh ${UTL_SCRIPTDIR}/setup_vsclaunch.sh "${REPO}"

if [ -z "${SRV}${USR}${PWD}" ] && [ -n "${REPO}" ] ; then
    exit 0
elif [ -z "${SRV}" ] || [ -z "${USR}" ] || [ -z "${PWD}" ] ; then
    usage "$0"
    exit 1
fi

NAMESPACE=default
if [ -n "${NS}" ] ; then
    NAMESPACE="${NS}"
fi

SECRET=registrykey
if [ -n "${SEC}" ] ; then
    SECRET="${SEC}"
fi

echo -n "Creating secret ... "
kubectl -n "${NAMESPACE}" delete secret "${SECRET}" >/dev/null 2>&1
kubectl -n "${NAMESPACE}" create secret docker-registry "${SECRET}" --docker-server="${SRV}" \
        --docker-username="${USR}" --docker-password="${PWD}"
echo "Done."
echo -n "Patching service account ... "
PATCH='{ "imagePullSecrets": [{"name": "'${SECRET}'"}]}'
kubectl -n "${NAMESPACE}" patch serviceaccount default -p "${PATCH}"
echo "Done."
