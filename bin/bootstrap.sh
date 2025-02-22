#!/bin/bash

flux install

flux create secret git homelab --url=ssh://git@github.com/lindblombr/homelab --ssh-key-algorithm=ecdsa --ssh-ecdsa-curve=p521
flux create source git homelab --url=ssh://git@github.com/lindblombr/homelab --branch main --secret-ref homelab
flux create kustomization homelab --source=GitRepository/homelab --path=./manifests --prune=true --interval=5m
