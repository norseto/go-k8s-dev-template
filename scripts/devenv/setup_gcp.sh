#!/bin/sh
set -e

####################################
# GCP setup                     #
####################################
SCRIPTDIR=$( cd "$( dirname "$0" )" && pwd )
CLUSTER=""
ZONE=""
REGION=""
PROJECT=""
REGISTRY=""

while [ $# -gt 0 ]
do
    case "$1" in
    "-p") shift; PROJECT=$1; shift ;;
    "-c") shift; CLUSTER=$1; shift ;;
    "-g") shift; REGISTRY=$1; shift ;;
    "-r") shift; REGION="--region $1"; shift ;;
    "-z") shift; ZONE="--zone $1"; shift ;;
    *)  echo "Usage: $0 -c clustername -p project -g registry [-r cluster_region | -z cluster_zone]" 1>&2 ; exit 1 ;;
    esac
done

if [ "x${CLUSTER}" = "x" ] || [ "x${PROJECT}" = "x" ] || [ "x${REGISTRY}" = "x" ]|| [ "x${REGION}${ZONE}" = "x" ]  ; then
    echo "Usage: $0 -c clustername -p porject -g registry [-r cluster_region | -z cluster_zone]" 1>&2
    exit 1
fi

echo "Launching GCP login..."
gcloud auth login
gcloud config set project ${PROJECT}
gcloud container clusters get-credentials ${CLUSTER} ${REGION} ${ZONE}
yes | gcloud auth configure-docker

echo "Recreating launch.json setting image registry = ${REGISTRY}"
sh ${SCRIPTDIR}/utils/setup_vsclaunch.sh "${REGISTRY}"
