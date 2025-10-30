#!/bin/bash
# ==========================================================
# Script: create_project_db.sh
# ----------------------------------------------------------
# Cria um novo banco e usuário dentro do Postgres da infra
# Uso:
#   bash scripts/create_project_db.sh <nome_projeto> <usuario> <senha>
# Exemplo:
#   bash scripts/create_project_db.sh retail retail_user retail_pass
# ==========================================================

PROJECT_NAME=$1
USER_NAME=$2
USER_PASS=$3

if [ -z "$PROJECT_NAME" ] || [ -z "$USER_NAME" ] || [ -z "$USER_PASS" ]; then
  echo "❌ Uso incorreto!"
  echo "👉 Exemplo: bash scripts/create_project_db.sh retail retail_user retail_pass"
  exit 1
fi

DB_NAME="db_${PROJECT_NAME}"

echo "🚀 Criando banco e usuário para o projeto: $PROJECT_NAME"
echo "   Banco: $DB_NAME"
echo "   Usuário: $USER_NAME"

# Detectar se Postgres está em Docker ou K8s
if docker ps --format '{{.Names}}' | grep -q "postgres"; then
  echo "🐳 Ambiente Docker detectado."
  docker exec -i postgres psql -U dw_user -d dw <<EOF
CREATE DATABASE ${DB_NAME};
CREATE USER ${USER_NAME} WITH ENCRYPTED PASSWORD '${USER_PASS}';
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${USER_NAME};
EOF

elif kubectl get pods -n data | grep -q "postgres"; then
  echo "☸️ Ambiente Kubernetes detectado."
  POD=$(kubectl get pods -n data -l app.kubernetes.io/name=postgresql -o jsonpath="{.items[0].metadata.name}")
  kubectl exec -i $POD -n data -- psql -U dw_user -d dw <<EOF
CREATE DATABASE ${DB_NAME};
CREATE USER ${USER_NAME} WITH ENCRYPTED PASSWORD '${USER_PASS}';
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${USER_NAME};
EOF

else
  echo "❌ Nenhum container/pod do Postgres encontrado!"
  exit 1
fi

echo "✅ Banco e usuário criados com sucesso!"
echo "🔗 String de conexão:"
echo "   postgresql://${USER_NAME}:${USER_PASS}@postgres:5432/${DB_NAME}"
