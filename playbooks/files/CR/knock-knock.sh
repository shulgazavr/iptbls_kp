#!/bin/bash

#user="$1"
user="root"
target_host="192.168.255.1"
ports="6328 4811 15547"

for i in $ports; do 
  nmap -Pn --host_timeout 201 --max-retries 0 -p "$i" "$target_host"
done 

ssh "$user"@"$target_host"
