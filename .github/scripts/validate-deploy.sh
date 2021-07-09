#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

if [[ -f .kubeconfig ]]; then
  KUBECONFIG=$(cat .kubeconfig)
else
  KUBECONFIG="${PWD}/.kube/config"
fi
export KUBECONFIG

if ! oc get job ibm-toolkit-install -n default 1> /dev/null 2> /dev/null; then
  echo "ibm-toolkit-install job not created"
  exit 1
fi
