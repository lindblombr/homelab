#!/bin/bash

set -Eeu

BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

sudo dnf install -y golang

go install sigs.k8s.io/kind@v0.33.0

# Install kubectl if it is not present
if ! [[ -f /usr/local/bin/kubectl ]]; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
  echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi

PATH=${PATH}:${HOME}/go

# allow firewall for api server and ingress ports 
sudo firewall-cmd --add-port=80/tcp --permanent
sudo firewall-cmd --add-port=443/tcp --permanent
sudo firewall-cmd --add-port=6443/tcp --permanent
sudo firewall-cmd --reload

# Allow port 80 to be bound for control plane to host for ingress
if ! [[ -f /etc/sysctl.d/99-unprivileged-port-start-80.conf ]]; then
  cat <<EOF | sudo tee /etc/sysctl.d/99-unprivileged-port-start-80.conf
net.ipv4.ip_unprivileged_port_start=80
EOF
fi

if ! [[ -f /etc/sysctl.d/99-inotify.conf ]]; then
  cat <<EOF | sudo tee /etc/sysctl.d/99-inotify.conf
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=524288
EOF
fi

sudo sysctl --system

# Create hostPath volume directories
sudo mkdir -p /data/volumes
sudo chown ${USER}:${USER} /data/volumes
mkdir -p /data/volumes/worker-0 /data/volumes/worker-1 /data/volumes/worker-2

kind create cluster --config kind-lab0.yaml

if ! [[ -f /usr/local/bin/flux ]]; then
  curl -s https://fluxcd.io/install.sh | sudo bash
fi

source ${BASE_DIR}/bootstrap.sh
