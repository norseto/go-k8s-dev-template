#!/bin/sh
set -e

#####################################
# Local setup script - Run in local #
#####################################
ENV_SCRIPTDIR=$( cd "$( dirname "$0" )" && pwd )
SCRIPTDIR="${ENV_SCRIPTDIR}/.."
HOST_IP=$1
VMNAME=$2

sh ${SCRIPTDIR}/utils/setup_vsclaunch.sh "${HOST_IP}:32000"

