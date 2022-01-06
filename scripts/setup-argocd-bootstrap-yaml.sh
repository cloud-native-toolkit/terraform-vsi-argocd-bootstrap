#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

OUTPUT_FILE="$1"

OUTPUT_DIR=$(dirname "${OUTPUT_FILE}")
mkdir -p "${OUTPUT_DIR}"

"${BIN_DIR}/helm" template \
  ibm-toolkit-install \
  ibm-toolkit-install \
  --repo https://charts.cloudnativetoolkit.dev \
  --namespace default \
  --set config.gitops_config_repo_url=$GITOPS_CONFIG_REPO_URL \
  --set config.gitops_config_username=$GITOPS_CONFIG_USERNAME \
  --set config.gitops_config_token=$GITOPS_CONFIG_TOKEN \
  --set config.gitops_bootstrap_path=$GITOPS_BOOTSTRAP_PATH \
  --set config.ingress_subdomain=$INGRESS_SUBDOMAIN \
  --set config.sealed_secret_cert=$SEALED_SECRET_CERT \
  --set config.sealed_secret_private_key=$SEALED_SECRET_PRIVATE_KEY \
  --set repo.url=https://github.com/cloud-native-toolkit/terraform-vsi-argocd-bootstrap \
  --set repo.branch=$BOOTSTRAP_BRANCH \
  --set repo.path=terraform > "${OUTPUT_FILE}"
