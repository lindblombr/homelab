#!/bin/bash

flux install

flux create secret git homelab --url=ssh://git@github.com/lindblombr/homelab --ssh-key-algorithm=ecdsa --ssh-ecdsa-curve=p521
flux create source git homelab --url=ssh://git@github.com/lindblombr/homelab --branch main --secret-ref homelab
flux create kustomization homelab-stage1 --source=GitRepository/homelab --path=./stage1 --prune=true --interval=5m
