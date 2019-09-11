#!/bin/sh

kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml

helm repo add openfaas https://openfaas.github.io/faas-netes/

PASSWORD=$(head -c 12 /dev/urandom | shasum| cut -d' ' -f1)

kubectl -n openfaas apply secret generic basic-auth \
        --from-literal=basic-auth-user=admin \
        --from-literal=basic-auth-password="$PASSWORD"

echo $PASSWORD > gateway-password.txt

helm repo update \
    && helm upgrade --tls openfaas --install openfaas/openfaas \
            --namespace openfaas \
            --set basic_auth=true \
            --set functionNamespace=openfaas-fn \
            --set faasIdler.dryRun=false \
            --values tls.yaml \
            --values values.yaml


