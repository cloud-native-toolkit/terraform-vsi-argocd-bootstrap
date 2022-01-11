#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

OUTPUT_DIR="$1"
mkdir -p "${OUTPUT_DIR}"

CREATE_FILE="init-argocd.sh"
DESTROY_FILE="destroy-argocd.sh"

set -x

cat "${MODULE_DIR}/scripts/${CREATE_FILE}" | \
  sed "s~ENV_IBMCLOUD_API_KEY~${IBMCLOUD_API_KEY}~g" | \
  sed "s~ENV_SERVER_URL~${SERVER_URL}~g" \
  > "${OUTPUT_DIR}/${CREATE_FILE}"

cat "${MODULE_DIR}/scripts/${DESTROY_FILE}" | \
  sed "s~ENV_IBMCLOUD_API_KEY~${IBMCLOUD_API_KEY}~g" | \
  sed "s~ENV_SERVER_URL~${SERVER_URL}~g" \
  > "${OUTPUT_DIR}/${DESTROY_FILE}"

chmod +x "${OUTPUT_DIR}/*.sh"
