#!/bin/sh
set -e

####################################
# Okteto setup                     #
####################################
SCRIPTDIR=$( cd "$( dirname "$0" )" && pwd )
NAME=""
TOKEN=""

while [ $# -gt 0 ]
do
    case "$1" in
    "-t") shift; TOKEN=$1; shift ;;
    *) NAME=$1 ; shift ;;
    esac
done

if [ "x${NAME}" = "x" ] || [ "x${TOKEN}" = "x" ] ; then
    echo "Usage: $0 [-t tooken] account" 1>&2
    exit 1
fi

echo "Logging in Okteto..."
docker login registry.cloud.okteto.net -u ${NAME} -p ${TOKEN}
okteto login -t ${TOKEN}
okteto namespace ${NAME}
sh ${SCRIPTDIR}/utils/setup_vsclaunch.sh "registry.cloud.okteto.net/${NAME}"

