#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

VALUES_FILE="$1"
OUTPUT_FILE="$2"

export PATH="${BIN_DIR}:${PATH}"

OUTPUT_DIR=$(dirname "${OUTPUT_FILE}")
mkdir -p "${OUTPUT_DIR}"

SOURCE_FILE="${MODULE_DIR}/config/cloud-init.yaml"

cat "${SOURCE_FILE}" | \
  sed -E "s~CLUSTER_PASSWORD=.*~CLUSTER_PASSWORD=\"${IBMCLOUD_API_KEY}\"~g" | \
  sed -E "s~SERVER_URL=.*~SERVER_URL=\"${SERVER_URL}\"~g" \
  > "${OUTPUT_FILE}"

export VALUES_CONTENT=$(cat "${VALUES_FILE}")

yq4 e -i -P '.write_files[0].content = ENV(VALUES_CONTENT)}' "${OUTPUT_FILE}"
