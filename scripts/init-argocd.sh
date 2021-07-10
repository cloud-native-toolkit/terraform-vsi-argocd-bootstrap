#!/usr/bin/env bash

IBMCLOUD_API_KEY="ENV_IBMCLOUD_API_KEY"
SERVER_URL="ENV_SERVER_URL"
GITOPS_CONFIG_REPO_URL="ENV_CONFIG_REPO_URL"
GITOPS_CONFIG_USERNAME="ENV_CONFIG_USERNAME"
GITOPS_CONFIG_TOKEN="ENV_CONFIG_TOKEN"
GITOPS_BOOTSTRAP_PATH="ENV_BOOTSTRAP_PATH"
BOOTSTRAP_BRANCH="ENV_BOOTSTRAP_BRANCH"

# install oc cli
OPENSHIFT_CLI_VERSION="4.7.2"
HELM_VERSION="3.6.2"

curl -sL https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OPENSHIFT_CLI_VERSION}/openshift-client-linux.tar.gz --output oc-client.tar.gz && \
    mkdir tmp && \
    cd tmp && \
    tar xzf ../oc-client.tar.gz && \
    mv ./oc /usr/local/bin/oc && \
    chmod +x /usr/local/bin/oc && \
    cd .. && \
    rm -rf ./tmp && \
    rm oc-client.tar.gz

curl -sL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz && \
    mkdir tmp && \
    cd tmp && \
    tar xzf ../helm.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm &&
    cd .. && \
    rm -rf ./tmp &&
    rm helm.tar.gz

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
  --set repo.branch=$BOOTSTRAP_BRANCH \
  --set repo.path=terraform | \
  oc apply -f -
