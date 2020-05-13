#!/bin/bash
GREEN="\033[1;32m"
NOCOLOR="\033[0m"
HOST='https://www.google.com'

echo -e "\n${GREEN} Verifying curl fails from sleep to google${NOCOLOR}"
(set -x; kubectl exec $(kubectl -n default get pod -l app=sleep -o jsonpath={.items..metadata.name}) -c sleep -- curl $HOST -s -o /dev/null -w "%{http_code}\n")
sleep 1

echo -e ""
read -r -p "$(echo -e ${GREEN}Press return to continue...${NOCOLOR})"
clear

echo -e "\n${GREEN}Adding egress gateway${NOCOLOR}"
kubectl apply -f ./step6/egress-gateway.yaml
sleep 1

echo -e "\n${GREEN}Adding service entry${NOCOLOR}"
kubectl apply -f ./step6/service-entry.yaml
sleep 1

echo -e "\n${GREEN}Adding virtual service${NOCOLOR}"
kubectl apply -f ./step6/virtual-service.yaml
sleep 1

echo -e "\n${GREEN} Adding destination rule${NOCOLOR}"
kubectl apply -f ./step6/destination-rule.yaml
sleep 1

echo -e "\n${GREEN}This is what the egress gateway looks like${NOCOLOR}"
kubectl describe gateway istio-egressgateway
sleep 1

echo -e "\n${GREEN}This is what the service entry looks like${NOCOLOR}"
kubectl describe serviceentry
sleep 1

echo -e "\n${GREEN}This is what the virtual service looks like${NOCOLOR}"
kubectl describe virtualservice direct-google-through-egress-gateway
sleep 1

echo -e "\n${GREEN}This is what the destination rule looks like${NOCOLOR}"
kubectl describe destinationrule
sleep 1

echo -e ""
read -r -p "$(echo -e ${GREEN}Press return to continue...${NOCOLOR})"
clear

echo -e "\n${GREEN} Verifying curl is successful from sleep to google${NOCOLOR}"
(set -x; kubectl exec $(kubectl -n default get pod -l app=sleep -o jsonpath={.items..metadata.name}) -c sleep -- curl $HOST -s -o /dev/null -w "%{http_code}\n")
sleep 1

echo -e "\n${GREEN} Verifying egress traffic show up in egress logs${NOCOLOR}"
(set -x; kubectl -n istio-system logs $(kubectl -n istio-system get pod -l app=istio-egressgateway -o jsonpath={.items..metadata.name}) | grep www.google.com )
sleep 1

echo -e "\n${GREEN} Verifying curl is successful from not-istio namespace sleep to google${NOCOLOR}"
(set -x; kubectl -n not-istio exec $(kubectl -n not-istio get pod -l app=sleep -o jsonpath={.items..metadata.name}) -c sleep -- curl $HOST -s -o /dev/null -w "%{http_code}\n")
sleep 1

echo -e ""
read -r -p "$(echo -e ${GREEN}Press return to continue...${NOCOLOR})"
clear
