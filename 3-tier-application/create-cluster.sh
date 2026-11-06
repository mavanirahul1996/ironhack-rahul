#!/bin/bash
set -e

az group create \
  --name rg-rahul-aks \
  --location eastus

az aks create \
  --resource-group rg-rahul-aks \
  --name rahul-aks \
  --location eastus \
  --node-count 1 \
  --node-vm-size Standard_D2s_v3 \
  --generate-ssh-keys \
  --enable-managed-identity \
  --tier free

az aks get-credentials \
  --resource-group rg-rahul-aks \
  --name rahul-aks

kubectl get nodes
