#!/bin/bash
#
# A simple script to submit the Argo workflow to build the release.
#
# Usage submit_release_job.sh ${COMMIT}
#
# COMMIT=commit to build at
# release workflow will submit to kubeflow-ci until release cluster updated
set -ex

COMMIT=$1

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

JOB_NAME="katib-release"
JOB_TYPE=katib-release
BUILD_NUMBER=$(uuidgen)
BUILD_NUMBER=${BUILD_NUMBER:0:4}
REPO_OWNER=kubeflow
REPO_NAME=katib
ENV=test
DATE=`date +%Y%m%d`
PULL_BASE_SHA=${COMMIT:0:8}
VERSION_TAG="v${DATE}-${PULL_BASE_SHA}"
BUILD_NUMBER_LOWER=$(echo "$BUILD_NUMBER" | tr '[:upper:]' '[:lower:]')

PROW_VAR="JOB_NAME=${JOB_NAME},JOB_TYPE=${JOB_TYPE},REPO_NAME=${REPO_NAME}"
PROW_VAR="${PROW_VAR},REPO_OWNER=${REPO_OWNER},BUILD_NUMBER=${BUILD_NUMBER}" 
PROW_VAR="${PROW_VAR},PULL_BASE_SHA=${PULL_BASE_SHA}" 

cd ${ROOT}/test/workflows

ks param set --env=${ENV} workflows-v1alpha2 namespace kubeflow-test-infra
ks param set --env=${ENV} workflows-v1alpha2 name "${JOB_NAME}-${PULL_BASE_SHA}-${BUILD_NUMBER_LOWER}-${USER}"
ks param set --env=${ENV} workflows-v1alpha2 prow_env "${PROW_VAR}"
ks param set --env=${ENV} workflows-v1alpha2 versionTag "${VERSION_TAG}"
ks param set --env=${ENV} workflows-v1alpha2 registry gcr.io/kubeflow-images-public
ks param set --env=${ENV} workflows-v1alpha2 bucket kubeflow-releasing-artifacts
ks apply ${ENV} -c workflows-v1alpha2