#!/bin/sh

for i in {1..10000}; do (echo </dev/tcp/192.168.1.110/$i) &>/dev/null  && echo -e "\n[+] Open port at:\t$i" || echo -n "."; done
