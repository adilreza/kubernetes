#!/bin/bash -e

# Usage ./generatekube.sh ( namespace )


SA_SECRET=$( kubectl get sa -n $1 $1-user -o jsonpath='{.secrets[0].name}' )

# Pull the bearer token and cluster CA from the service account secret.
BEARER_TOKEN=$( kubectl get secrets -n $1 $SA_SECRET -o jsonpath='{.data.token}' | base64 -d )
kubectl get secrets -n $1 $SA_SECRET -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
kubectl get secret -n $1 $SA_SECRET -o json > azureSecret.json

CLUSTER_URL=$( kubectl config view -o jsonpath='{.clusters[0].cluster.server}' )

echo $CLUSTER_URL


KUBECONFIG=kubeconfig

kubectl config --kubeconfig=$KUBECONFIG \
    set-cluster \
    $CLUSTER_URL \
    --server=$CLUSTER_URL \
    --certificate-authority=ca.crt \
    --embed-certs=true

kubectl config --kubeconfig=$KUBECONFIG \
    set-credentials $1-user --token=$BEARER_TOKEN

kubectl config --kubeconfig=$KUBECONFIG \
    set-context lke71781-ctx \
    --cluster=$CLUSTER_URL \
    --user=$1-user

kubectl config --kubeconfig=$KUBECONFIG \
    use-context lke71781-ctx

kubectl config --kubeconfig=$KUBECONFIG \
    set-context --current --namespace=$1

echo "kubeconfig written to file \"$KUBECONFIG\""
