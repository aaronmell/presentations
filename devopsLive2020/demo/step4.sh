#!/bin/bash
GREEN="\033[1;32m"
NOCOLOR="\033[0m"
HOST='https://bookinfo.devops.live/productpage'

clear
echo -e "${GREEN}Adding Request Authentication${NOCOLOR}"
kubectl apply -f ./step4/request-authentication.yaml
sleep 1

echo -e "\n${GREEN}Adding Authorization Policy${NOCOLOR}"
kubectl apply -f ./step4/authorization-policy.yaml
sleep 1

echo -e "\n${GREEN}This is what the request authentication looks like${NOCOLOR}"
kubectl -n istio-system describe requestauthentication
sleep 1

echo -e "\n${GREEN}This is what the authorization policy looks like${NOCOLOR}"
kubectl -n istio-system describe authorizationpolicy
sleep 1

echo -e ""
read -r -p "$(echo -e ${GREEN}Press return to continue...${NOCOLOR})"
clear

echo -e "\n${GREEN}Hitting Site without JWT${NOCOLOR}"
(set -x; curl -k $HOST -s -o /dev/null -w "%{http_code}\n")
sleep 1

echo -e "\n${GREEN}Hitting Site with invalid JWT${NOCOLOR}"
(set -x; curl -k --header "Authorization: devops live" $HOST -s -o /dev/null -w "%{http_code}\n")
sleep 1

echo -e "\n${GREEN}Hitting Site with valid JWT${NOCOLOR}"
TOKEN=$(curl https://raw.githubusercontent.com/istio/istio/release-1.5/security/tools/jwt/samples/demo.jwt -s)
(set -x; curl -k --header "Authorization: Bearer $TOKEN" $HOST -s -o /dev/null -w "%{http_code}\n")
sleep 1
