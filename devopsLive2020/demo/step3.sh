#!/bin/bash
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

clear
echo -e "${GREEN}Installing Sleep into default namespace${NOCOLOR}"
kubectl apply -f ./step3/sleep.yaml
sleep 5

echo -e "\n${GREEN}The default namespace looks like this now${NOCOLOR}"
kubectl get pods
sleep 1

echo -e "\n${GREEN}Enabling peer authentication${NOCOLOR}"
kubectl apply -f ./step3/peer-authentication.yaml
sleep 1

echo -e "\n${GREEN}This is what the peer authentication looks like${NOCOLOR}"
kubectl -n istio-system describe PeerAuthentication
sleep 1

echo -e "\n${GREEN} Verifying I can curl from sleep to productpage${NOCOLOR}"
(set -x; kubectl exec $(kubectl -n default get pod -l app=sleep -o jsonpath={.items..metadata.name}) -c sleep -- curl productpage:9080 -s -o /dev/null -w "%{http_code}\n")
sleep 1

echo -e ""
read -r -p "$(echo -e ${GREEN}Press return to continue...${NOCOLOR})"
clear

echo -e "\n${GREEN}Installing Sleep into a namespace not controller by istio${NOCOLOR}"
kubectl create namespace not-istio
kubectl apply -f ./step3/sleep.yaml -n not-istio
sleep 1

echo -e "\n${GREEN}The non-istio namespace looks like this now${NOCOLOR}"
kubectl -n not-istio get pods
sleep 1

echo -e "\n${GREEN} Verifying I cannot curl from non-istio sleep to productpage${NOCOLOR}"
(set -x; kubectl -n not-istio exec $(kubectl -n not-istio get pod -l app=sleep -o jsonpath={.items..metadata.name}) -c sleep -- curl productpage.default:9080 -s -o /dev/null -w "%{http_code}\n")
