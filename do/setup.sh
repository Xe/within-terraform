#!/bin/bash

set -e
set -x

doctl kubernetes cluster kubeconfig save kubermemes

kubectl apply -f- <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF

dyson env > dyson.env
source dyson.env
rm dyson.env

openssl genrsa -out ./ca.key.pem 4096
openssl req -key ca.key.pem -new -x509 -days 7300 -sha256 -out ca.cert.pem -extensions v3_ca
openssl genrsa -out ./tiller.key.pem 4096
openssl genrsa -out ./helm.key.pem 4096
openssl req -key tiller.key.pem -new -sha256 -out tiller.csr.pem
openssl req -key helm.key.pem -new -sha256 -out helm.csr.pem
openssl x509 -req -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -in tiller.csr.pem -out tiller.cert.pem -days 365
openssl x509 -req -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -in helm.csr.pem -out helm.cert.pem  -days 365

helm init \
     --tiller-tls \
     --tiller-tls-cert ./tiller.cert.pem \
     --tiller-tls-key ./tiller.key.pem \
     --tiller-tls-verify \
     --tls-ca-cert ca.cert.pem \
     --upgrade \
     --service-account tiller \
     --force-upgrade

sleep 2

helm install stable/nginx-ingress \
     --name nginx \
     --tls \
     --set controller.publishService.enabled=true \
     --set rbac.create=true \
     --values nginx-values.yaml

helm install stable/external-dns \
     --tls \
     --name edns \
     --set provider=cloudflare \
     --set cloudflare.apiKey=$CLOUDFLARE_TOKEN \
     --set cloudflare.email=$CLOUDFLARE_EMAIL \
     --set rbac.create=true \
     --set cloudflare.proxied=false

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.10/deploy/manifests/00-crds.yaml
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm install jetstack/cert-manager \
     --namespace cert-manager \
     --tls

sleep 10

kubectl apply --namespace cert-manager -f- <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-creds
data:
  email: $(echo -n $CLOUDFLARE_EMAIL | base64 -w 0)
  password: $(echo -n $CLOUDFLARE_TOKEN | base64 -w 0)
EOF

kubectl apply -f- <<EOF
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    email: me@christine.website
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: example-issuer-account-key
    solvers:
    - dns01:
        cloudflare:
          email: $CLOUDFLARE_EMAIL
          # A secretKeyRef to a cloudflare api key
          apiKeySecretRef:
            name: cloudflare-creds
            key: password
EOF

kubectl apply -f- <<EOF
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
  # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: me@christine.website
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-prod
    # Enable the HTTP-01 challenge provider
    solvers:
    - dns01:
        cloudflare:
          email: $CLOUDFLARE_EMAIL
          # A secretKeyRef to a cloudflare api key
          apiKeySecretRef:
            name: cloudflare-creds
            key: password
EOF

kubectl create secret generic regcred \
        --from-file=.dockerconfigjson=~/.docker/config.json \
        --type=kubernetes.io/dockerconfigjson --namespace apps

