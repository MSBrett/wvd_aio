#!/bin/sh
# Change these vars to fit your needs
prefix='acme'
domainName='wvd.acme.com'
location='westus'
subscription='workload'
adminUserName='azureadmin'
numSessionHosts=2

# Read the password
echo 'Enter a password for the domain admininstrator account'
read adminPassword

# Script main
now=$(date -j +%F)
then=$(date -v+29d -j -f "%Y-%m-%d" $now +%F)
timeOfDay="T00:00:01.000Z"
tokenExpirationTime="$then$timeOfDay"
infra="$prefix-$location-wvd-infra"
hosts="$prefix-$location-wvd-hosts"

az account set --subscription $subscription
az group create --name $infra --location $location
az group create --name $hosts --location $location

az deployment group create \
    --resource-group "$infra" \
    --template-file infrastructure.json \
    --parameters @infrastructure.parameters.json \
    --parameters "adminUserName=$adminUserName" "adminPassword=$adminPassword" "deployDomain=true" "domainName=$domainName" "location=$location"

az deployment group create \
    --resource-group "$hosts" \
    --template-file workspace.json \
    --parameters @workspace.parameters.json \
    --parameters "location=$location" "workspaceName=$prefix-$location-workspace"

az deployment group create \
    --resource-group "$hosts" \
    --template-file hostpool.json \
    --parameters @hostpool.parameters.json \
    --parameters "location=$location" "resourceGroup=$hosts" "virtualNetworkResourceGroupName=$infra" "workspaceResourceGroup=$hosts" "vmResourceGroup=$hosts" "vmNumberOfInstances=$numSessionHosts" "existingVnetName=vnet-WindowsVirtualDesktop" "existingSubnetName=HostPool1" "administratorAccountUsername=$adminUserName@$domainName" "administratorAccountPassword=$adminPassword" "vmLocation=$location" "workspaceLocation=$location" "workSpaceName=$prefix-$location-workspace" "vmNamePrefix=hp1" "tokenExpirationTime=$tokenExpirationTime"
