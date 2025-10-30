#!/bin/bash
set -e
kubectl create namespace data || true
kubectl apply -f infra/k8s/dbt/ || true
