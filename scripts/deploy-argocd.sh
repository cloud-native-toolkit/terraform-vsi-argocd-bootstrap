#!/usr/bin/env bash

RESOURCE_FILE="$1"

if [[ -z "${RESOURCE_FILE}" ]]; then
  RESOURCE_FILE="./argocd-bootstrap.yaml"
fi

set -x

# login to cluster
oc login -u apikey -p "${IBMCLOUD_API_KEY}" "${SERVER_URL}"

oc delete job ibm-toolkit-install -n default || echo "No job to delete"

oc apply -f "${RESOURCE_FILE}"
