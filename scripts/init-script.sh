#!/usr/bin/env bash

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
