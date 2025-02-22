#!/bin/bash

function cleanup() {
  kill ${pf_pid}
  exit 0
}

kubectl -n prometheus-system port-forward service/prometheus-system-kube-prometheus-stack-grafana 3000:80 &
export pf_pid=$!

trap cleanup EXIT SIGINT SIGTERM

sleep 2

open http://localhost:3000

kubectl -n prometheus-system get secret/prometheus-system-kube-prometheus-stack-grafana -o json | jq -r '"User: \(.data."admin-user" | @base64d) Password: \(.data."admin-password" | @base64d)"'
wait
