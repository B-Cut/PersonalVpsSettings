#!/bin/bash

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <domain-name> <domain-name> <domain-name> ..."
    exit -1
fi

cert_output=$(/usr/local/bin/certbot certificates)



for domain in "$@"
do 
    echo $cert_output | grep $domain -q

    if [[ $? -ne 0 ]]; then
        exit 0
    fi
done

exit 1