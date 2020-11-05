#!/bin/sh
set -e

####################################
# AWS setup                     #
####################################
SCRIPTDIR=$( cd "$( dirname "$0" )" && pwd )
CLUSTER=""
PROFILE="go-k8s"
REPO_PATH=""

while [ $# -gt 0 ]
do
    case "$1" in
    "-c") shift; CLUSTER=$1; shift ;;
    "-r") shift; REPO_PATH=$1; shift ;;
    *)  echo "Usage: $0 -c clustername [-r repository path prefix]" 1>&2 ; exit 1 ;;
    esac
done

if [ "x${CLUSTER}" = "x" ] ; then
    echo "Usage: $0 [-c clustername]" 1>&2
    exit 1
fi

echo "Launching aws configure..."
aws configure --profile=${PROFILE}

REGION=$(aws configure list --profile=${PROFILE} | grep "^\s*region" | awk '{print $2}')
ACCOUNT_ID=$(aws sts get-caller-identity --profile=go-k8s --output=json | jq -r .Account)
ECR="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
if [ "x" = "${REPO_PATH}" ] ; then
    REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
else
    REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_PATH}"
fi
echo "Getting Kubernetes credential..."
aws eks update-kubeconfig --region ${REGION} --name ${CLUSTER}
echo "Recreating launch.json setting image registry = ${REGISTRY}"
sh ${SCRIPTDIR}/utils/setup_vsclaunch.sh "${REGISTRY}"
echo "Run export AWS_PROFILE=${PROFILE}"