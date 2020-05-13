#!/bin/bash
GREEN="\033[1;32m"
NOCOLOR="\033[0m"
HOST='https://www.google.com'

echo -e "\n${GREEN} This is what a network policy looks like${NOCOLOR}"
cat ./step7/networkPolicy.yml
sleep 1

echo -e ""
read -r -p "$(echo -e ${GREEN}Press return to continue...${NOCOLOR})"
clear
