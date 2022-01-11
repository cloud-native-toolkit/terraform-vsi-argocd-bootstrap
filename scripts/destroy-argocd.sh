#!/usr/bin/env bash

set -x

SOURCE_DIR=$(cd $(dirname "$0"); pwd -P)

RESOURCE_FILE="$1"

if [[ -z "${RESOURCE_FILE}" ]]; then
  RESOURCE_FILE="${SOURCE_DIR}/argocd-bootstrap.yaml"
fi

IBMCLOUD_API_KEY="ENV_IBMCLOUD_API_KEY"
SERVER_URL="ENV_SERVER_URL"

# install oc cli
OPENSHIFT_CLI_VERSION="4.7.2"

if ! command -v oc; then
  curl -sL https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OPENSHIFT_CLI_VERSION}/openshift-client-linux.tar.gz --output oc-client.tar.gz && \
      mkdir tmp && \
      cd tmp && \
      tar xzf ../oc-client.tar.gz && \
      mv ./oc /usr/local/bin/oc && \
      chmod +x /usr/local/bin/oc && \
      cd .. && \
      rm -rf ./tmp && \
      rm oc-client.tar.gz
fi

# login to cluster
oc login -u apikey -p $IBMCLOUD_API_KEY $SERVER_URL

oc delete job ibm-toolkit-install -n default || echo "No job to delete"
