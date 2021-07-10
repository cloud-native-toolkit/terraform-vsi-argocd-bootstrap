#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

OUTPUT_FILE="$1"

OUTPUT_DIR=$(dirname "${OUTPUT_FILE}")
mkdir -p "${OUTPUT_DIR}"

SOURCE_FILE="${MODULE_DIR}/scripts/init-argocd.sh"

set -x

cat "${SOURCE_FILE}" | \
  sed "s~ENV_IBMCLOUD_API_KEY~${IBMCLOUD_API_KEY}~g" | \
  sed "s~ENV_SERVER_URL~${SERVER_URL}~g" | \
  sed "s~ENV_CONFIG_REPO_URL~${CONFIG_REPO_URL}~g" | \
  sed "s~ENV_CONFIG_USERNAME~${CONFIG_USERNAME}~g" | \
  sed "s~ENV_CONFIG_TOKEN~${CONFIG_TOKEN}~g" | \
  sed "s~ENV_BOOTSTRAP_PATH~${BOOTSTRAP_PATH}~g" | \
  sed "s~ENV_INGRESS_SUBDOMAIN~${INGRESS_SUBDOMAIN}~g" | \
  sed "s~ENV_BOOTSTRAP_BRANCH~${BOOTSTRAP_BRANCH}~g" \
  > "${OUTPUT_FILE}"

chmod +x "${OUTPUT_FILE}"
