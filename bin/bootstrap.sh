#!/bin/bash

flux install

flux create source git homelab --url=https://github.com/lindblombr/homelab --branch main
flux create secret git homelab --url=ssh://git@github.com/lindblombr/homelab --ssh-key-algorithm=ecdsa \
  --ssh-ecdsa-curve=p521
flux create kustomization homelab --source=GitRepository/homelab --path=./manifests --prune=true --interval=5m
