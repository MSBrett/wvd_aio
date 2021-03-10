#!/bin/sh

# Change these vars to fit your needs
prefix='acme'
location='westus'
subscription='workload'

# Script main
infra="$prefix-$location-wvd-infra"
hosts="$prefix-$location-wvd-hosts"
az account set --subscription $subscription
az group delete --name $hosts --yes --no-wait
az group delete --name $infra --yes