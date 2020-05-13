#!/bin/bash
GREEN="\033[1;32m"
NOCOLOR="\033[0m"



clear
echo -e "${GREEN}Installing Istio 1.5.2${NOCOLOR}"
istioctl manifest apply --set profile=demo -f ./step1/operator.yaml
sleep 10

echo -e "\n${GREEN}Configuring default namespace for automatic injection${NOCOLOR}"
kubectl label namespace default istio-injection=enabled
sleep 1

echo -e "\n${GREEN}Installing bookinfo application${NOCOLOR}"
kubectl apply -f step1/bookinfo.yaml
sleep 10

echo -e "\n${GREEN}Installing istio gateway for bookinfo application${NOCOLOR}"
kubectl apply -f step1/bookinfo-gateway.yaml

echo -e ""
read -r -p "$(echo -e ${GREEN}Press return to continue...${NOCOLOR})"

clear
echo -e "${GREEN}This is what the namespace looks like${NOCOLOR}"
kubectl describe ns default
sleep 1

echo -e "\n${GREEN}This is what the bookinfo application looks like${NOCOLOR}"
kubectl -n default get pods
sleep 1

echo -e ""
read -r -p "$(echo -e ${GREEN}Press return to continue...${NOCOLOR})"

clear
echo -e "\n${GREEN}This is what the istio pods looks like${NOCOLOR}"
kubectl -n istio-system get pods
sleep 1

echo -e "\n${GREEN}This is what the gateway looks like${NOCOLOR}"
kubectl -n default describe gateway bookinfo-gateway
sleep 1

echo -e "\n${GREEN}This is what the virtual service looks like${NOCOLOR}"
kubectl -n default describe virtualservice bookinfo

echo -e ""
read -r -p "$(echo -e ${GREEN}Press return to continue...${NOCOLOR})"

echo -e "\n${GREEN} Verifying bookinfo is running on 80${NOCOLOR}"
(set -x; curl http://bookinfo.devops.live/productpage -s -o /dev/null -w "%{http_code}\n")
sleep 1
