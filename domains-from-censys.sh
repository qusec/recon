#!/bin/sh

json_dir=$1
scope=$2$
cat $json_dir/*.json | jq -r '.services[] | .tls.certificates.leaf_data.names | select( . != null)[]' | grep -i $scope 
