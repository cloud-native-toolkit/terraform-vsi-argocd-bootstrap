#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

if [[ -f .kubeconfig ]]; then
  KUBECONFIG=$(cat .kubeconfig)
else
  KUBECONFIG="${PWD}/.kube/config"
fi
export KUBECONFIG

NAMESPACE=$(cat .namespace)

oc get job -n default

if ! oc get job ibm-toolkit-install -n default 1> /dev/null 2> /dev/null; then
  echo "ibm-toolkit-install job not created"
  exit 1
fi

oc get all -n "${NAMESPACE}"

IN="artifactory;sonarqube;dashboard"

IFS=';' read -ra DEPLOYMENTS <<< "$IN"
for deployment in "${DEPLOYMENTS[@]}"; do
  # process "$i"
  count=0
  until kubectl get deployment "${deployment}" -n "${NAMESPACE}" 1> /dev/null 2> /dev/null || [[ $count -eq 20 ]]; do
    echo "Waiting for deployment: ${deployment}"
    count=$((count + 1))
    sleep 30
  done

  if [[ $count -eq 20 ]]; then
    echo "Timed out waiting for deployment to start: ${deployment}"
    kubectl get all -n "${NAMESPACE}"
    exit 1
  fi

  kubectl rollout status deployment "${deployment}" -n "${NAMESPACE}"
done
