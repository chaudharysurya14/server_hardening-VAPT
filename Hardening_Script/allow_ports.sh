#!/bin/bash
ports=()

for port in "${ports[@]}"; do 
    firewall-cmd --add-port="$port/tcp" --permanent 
done 

firewall-cmd --reload 
firewall-cmd --list-all
