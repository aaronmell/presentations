#!/bin/bash
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

clear
echo -e "${GREEN}Verifying Istio Namespace${NOCOLOR}"
kubectl get ns istio-system

echo -e "\n${GREEN}There are no pods running in default namespace${NOCOLOR}"
kubectl -n default get pods
echo -e ""

echo -e "\n${GREEN}Verifying bookinfo application isn't running${NOCOLOR}"
(set -x; curl http://bookinfo.devops.live/productpage)