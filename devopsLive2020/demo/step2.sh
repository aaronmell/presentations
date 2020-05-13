#!/bin/bash
GREEN="\033[1;32m"
NOCOLOR="\033[0m"
clear

echo -e "${GREEN}Adding Secret for TLS${NOCOLOR}"
kubectl create -n istio-system secret \
tls istio-ingressgateway-certs \
--key ./step2/certs/bookinfo.devops.live.key \
--cert ./step2/certs/bookinfo.devops.live.pem

echo -e "\n${GREEN}Adding TLS to Gateway${NOCOLOR}"
kubectl apply -f ./step2/bookinfo-gateway.yaml

echo -e "\n${GREEN} This is what my certificate secret looks like${NOCOLOR}"
kubectl -n istio-system describe secret bookinfo.devops.live
sleep 1

echo -e "\n${GREEN}This is what the gateway looks like${NOCOLOR}"
kubectl -n default describe gateway bookinfo-gateway
sleep 5

echo -e "\n${GREEN} Verifying bookinfo is now running on 443${NOCOLOR}"
(set -x; curl -k https://bookinfo.devops.live/productpage -s -o /dev/null -w "%{http_code}\n")
sleep 1