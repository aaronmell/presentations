#!/bin/bash
GREEN="\033[1;32m"
NOCOLOR="\033[0m"
HOST='https://bookinfo.devops.live/productpage'

clear
echo -e "${GREEN}Adding Authorization Policy${NOCOLOR}"
kubectl apply -f ./step5/authorization-policy2.yaml
sleep 1

echo -e "\n${GREEN}This is what the authorization policy looks like${NOCOLOR}"
kubectl -n istio-system describe authorizationpolicy
sleep 1

echo -e ""
read -r -p "$(echo -e ${GREEN}Press return to continue...${NOCOLOR})"
clear

echo -e "\n${GREEN}Hitting Site with invalid JWT ${NOCOLOR}"
TOKEN=$(curl https://raw.githubusercontent.com/istio/istio/release-1.5/security/tools/jwt/samples/demo.jwt -s)
(set -x; curl -k --header "Authorization: Bearer $TOKEN" $HOST -s -o /dev/null -w "%{http_code}\n")
sleep 1

echo -e "\n${GREEN}This is what our valid token looks like${NOCOLOR}"
TOKEN_GROUP=$(curl https://raw.githubusercontent.com/istio/istio/release-1.5/security/tools/jwt/samples/groups-scope.jwt -s) 
echo $TOKEN_GROUP | cut -d '.' -f2 - | base64 --decode -
sleep 1

echo -e "\n\n${GREEN}Hitting Site with valid JWT ${NOCOLOR}"
(set -x; curl -k --header "Authorization: Bearer $TOKEN_GROUP" $HOST -s -o /dev/null -w "%{http_code}\n")
sleep 1