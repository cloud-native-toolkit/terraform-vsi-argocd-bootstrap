#!/usr/bin/env bash

IBMCLOUD_API_KEY="ENV_IBMCLOUD_API_KEY"
SERVER_URL="ENV_SERVER_URL"
GITOPS_CONFIG_REPO_URL="ENV_CONFIG_REPO_URL"
GITOPS_CONFIG_USERNAME="ENV_CONFIG_USERNAME"
GITOPS_CONFIG_TOKEN="ENV_CONFIG_TOKEN"
GITOPS_BOOTSTRAP_PATH="ENV_BOOTSTRAP_PATH"

# login to cluster
oc login -u apikey -p $IBMCLOUD_API_KEY $SERVER_URL

oc delete job ibm-toolkit-install -n default || echo "No job to delete"

# create job with terraform image
helm template ibm-toolkit-install ibm-toolkit-install \
  --repo https://charts.cloudnativetoolkit.dev \
  --namespace default \
  --set config.gitops_config_repo_url=$GITOPS_CONFIG_REPO_URL \
  --set config.gitops_config_username=$GITOPS_CONFIG_USERNAME \
  --set config.gitops_config_token=$GITOPS_CONFIG_TOKEN \
  --set config.gitops_bootstrap_path=$GITOPS_BOOTSTRAP_PATH \
  --set repo.url=https://github.com/cloud-native-toolkit/terraform-vsi-argocd-bootstrap \
  --set repo.path=terraform | \
  oc apply -f -
