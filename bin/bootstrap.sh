#!/bin/bash

flux install

flux -n default create source helm ghcr-ingress-nginx --url  oci://ghcr.io/nginxinc/charts
flux -n default create source helm jetstack --url https://charts.jetstack.io
flux -n default create source helm prometheus-community --url https://prometheus-community.github.io/helm-charts

flux create helmrelease -n default nginx-ingress --source helmrepository/ghcr-ingress-nginx --chart nginx-ingress --chart-version 0.18.1 --target-namespace ingress-nginx --create-target-namespace

kubectl apply -f manifests/


kubectl apply -f - <<EOF
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: lab-issuer-root
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: lab-ca
  namespace: cert-manager
spec:
  isCA: true
  commonName: lab-ca
  secretName: root-secret
  privateKey:
    algorithm: ECDSA
    size: 256
  issuerRef:
    name: lab-issuer-root
    kind: ClusterIssuer
    group: cert-manager.io
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: lab-issuer
  namespace: cert-manager
spec:
  ca:
    secretName: root-secret
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: default-ingress
  namespace: ingress
spec:
  secretName: default-tls
  duration: 8640h # 360d
  renewBefore: 360h # 15d
  subject:
    organizations:
      - lab
  commonName: lab0.local
  isCA: false
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  usages:
    - server auth
    - client auth
  dnsNames:
    - lab0.local
  uris:
    - spiffe://cluster.local/ns/ingress/sa/nginx-ingress-microk8s-serviceaccount
  ipAddresses:
    - 192.168.50.200
  issuerRef:
    name: lab-issuer
    kind: ClusterIssuer
    group: cert-manager.io
EOF
