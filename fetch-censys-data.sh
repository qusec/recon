#!/bin/sh

ip=$1
json_file=$2
censys view $ip -f json -o $json_file
