#!/bin/sh

json_file=$1
scope=$2$
cat $json_file | jq -r '.services[] | .tls.certificates.leaf_data.names | select( . != null)[]' | grep -i $scope 
