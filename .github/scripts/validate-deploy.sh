#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

if [[ -f .kubeconfig ]]; then
  KUBECONFIG=$(cat .kubeconfig)
else
  KUBECONFIG="${PWD}/.kube/config"
fi
export KUBECONFIG

PUBLIC_IP=$(cat .public_ip)

NAMESPACE=$(cat .namespace)

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

SSH_DIR=$(cd "./.ssh"; pwd -P)

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

SSH_ID="${SSH_DIR}/id_ssh_key"

if [[ ! -f "${SSH_ID}" ]]; then
  echo ".ssh_key is missing: ${SSH_ID}"
  exit 1
fi

echo "SSH key"
cat "${SSH_ID}"

chmod -R 700 "${SSH_DIR}"

echo "Printing ssh log"
scp -vv -oStrictHostKeyChecking=accept-new -i "${SSH_ID}" "${PUBLIC_IP}:/tmp/init-argocd.log" ./init-argocd.log
cat init-argocd.log

oc get job -n default

if ! oc get job ibm-toolkit-install -n default 1> /dev/null 2> /dev/null; then
  echo "ibm-toolkit-install job not created"
  exit 1
fi

echo "Wait for ibm-toolkit-install job to complete"
oc wait --for=condition=complete job ibm-toolkit-install -n default

echo "Getting all resources in target namespace ${NAMESPACE}"
oc get all -n "${NAMESPACE}"

#IN="deployment/${NAMESPACE}-dashboard-developer-dashboard;statefulset/${NAMESPACE}-artifactory-artifactory;deployment/${NAMESPACE}-sonarqube-sonarqube"
IN="deployment/dashboard-developer-dashboard;statefulset/artifactory-artifactory"

IFS=';' read -ra DEPLOYMENTS <<< "$IN"
for resource in "${DEPLOYMENTS[@]}"; do
  # process "$i"
  count=0
  until kubectl get "${resource}" -n "${NAMESPACE}" 1> /dev/null 2> /dev/null || [[ $count -eq 20 ]]; do
    echo "Waiting for ${resource}"
    count=$((count + 1))
    sleep 60
  done

  if [[ $count -eq 20 ]]; then
    echo "Timed out waiting for resource to start: ${resource}"
    kubectl get all -n "${NAMESPACE}"
    exit 1
  fi

  kubectl rollout status "${resource}" -n "${NAMESPACE}"
done
