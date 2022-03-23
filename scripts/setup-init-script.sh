#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

INPUT=$(tee)

BIN_DIR=$(echo "${INPUT}" | grep "bin_dir" | sed -E 's/.*"bin_dir": ?"([^"]+)".*/\1/g')

export PATH="${BIN_DIR}:${PATH}"

eval "$(echo "${INPUT}" | jq -r '@sh "IBMCLOUD_API_KEY=\(.ibmcloud_api_key) SERVER_URL=\(.server_url) VALUES_CONTENT=\(.values_content)"')"

SOURCE_FILE="${MODULE_DIR}/config/cloud-init.yaml"

export VALUES_CONTENT

INIT_SCRIPT=$(cat "${SOURCE_FILE}" | sed -E "s~CLUSTER_PASSWORD=.*~CLUSTER_PASSWORD=\"${IBMCLOUD_API_KEY}\"~g" | sed -E "s~SERVER_URL=.*~SERVER_URL=\"${SERVER_URL}\"~g" | yq4 e -P '.write_files[0].content = ENV(VALUES_CONTENT)}' -)

jq -n --arg INIT_SCRIPT "${INIT_SCRIPT}" '{"init_script": $INIT_SCRIPT}'
