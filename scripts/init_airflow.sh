#!/bin/bash
set -e
kubectl create namespace data || true
helmfile -f infra/k8s/helmfile.yaml -l name=airflow apply || helmfile -f infra/k8s/helmfile.yaml apply
