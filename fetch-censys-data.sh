#!/bin/sh

ips_file=$1
out_dir=$2

mkdir -p $out_dir
while IFS= read -r ip 
do
    echo "Fetching censys data for IP="$ip
    #touch $out_dir/$ip.json
    censys view $ip -f json -o $out_dir/$ip.json
done < "$ips_file"
