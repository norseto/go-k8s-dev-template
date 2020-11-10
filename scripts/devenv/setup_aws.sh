#!/bin/sh
set -e

####################################
# AWS setup                     #
####################################
unset AWS_PROFILE AWS_DEFAULT_PROFILE
SCRIPTDIR=$( cd "$( dirname "$0" )" && pwd )
CLUSTER=""
PROFILE="go-k8s"
REPO_PATH=""
ROLE_ARN=""

while [ $# -gt 0 ]
do
    case "$1" in
    "-c") shift; CLUSTER=$1; shift ;;
    "-p") shift; REPO_PATH=$1; shift ;;
    "-r") shift; ROLE_ARN=$1; shift ;;
    *)  echo "Usage: $0 -c clustername [-p repository pathPrefix] [-r role_arn]" 1>&2 ; exit 1 ;;
    esac
done

if [ "x${CLUSTER}" = "x" ] ; then
    echo echo "Usage: $0 -c clustername [-p repository pathPrefix] [-r role_arn]" 1>&2
    exit 1
fi

echo "Launching aws configure..."
aws configure --profile=${PROFILE}

AWS_PROFILE=${PROFILE}
REGION=$(aws configure list --profile=${PROFILE} | grep "^\s*region" | awk '{print $2}')
ACCOUNT_ID=$(aws sts get-caller-identity --profile=${PROFILE} --output=json | jq -r .Account)
ECR="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
if [ "x" = "${REPO_PATH}" ] ; then
    REGISTRY="${ECR}"
else
    REGISTRY="${ECR}/${REPO_PATH}"
fi

echo "Logging in ECR ${ECR}..."
aws ecr get-login-password --region ${REGION} --profile=${PROFILE} | docker login --username AWS --password-stdin ${ECR}

echo "Recreating launch.json setting image registry = ${REGISTRY}"
sh ${SCRIPTDIR}/utils/setup_vsclaunch.sh "${REGISTRY}"

if [ "x" != "${ROLE_ARN}" ] ; then
    echo "Setup config for role ${ROLE_ARN}..."
    NEW_PROFILE="${PROFILE}-role"
    aws configure set region ${REGION} --profile=${NEW_PROFILE}
    aws configure set role_arn ${ROLE_ARN} --profile=${NEW_PROFILE}
    aws configure set source_profile ${PROFILE} --profile=${NEW_PROFILE}
    PROFILE=${NEW_PROFILE}
fi

echo "Getting Kubernetes credential for ${CLUSTER}(${REGION})..."
aws eks update-kubeconfig --region ${REGION} --name ${CLUSTER} --profile=${PROFILE}
echo "Run export AWS_PROFILE=${PROFILE}"
