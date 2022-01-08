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
  sed "s~ENV_SERVER_URL~${SERVER_URL}~g" \
  > "${OUTPUT_FILE}"

chmod +x "${OUTPUT_FILE}"
