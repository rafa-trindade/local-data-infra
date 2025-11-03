#!/bin/bash
# ==========================================================
# Script: create_project_db.sh
# ----------------------------------------------------------
# Cria um novo banco de dados e usuário dentro do Postgres da infra.
# Uso:
#   bash scripts/create_project_db.sh <nome_projeto> <usuario> <senha>
# Exemplo:
#   bash scripts/create_project_db.sh retail retail_user retail_pass
# ==========================================================

# Credenciais de administrador do PostgreSQL (usuário e senha do banco 'dw')
# Usa variáveis de ambiente como fallback para os valores padrão
PG_ADMIN_USER=${PG_ADMIN_USER:-dw_user}
PG_ADMIN_PASS=${PG_ADMIN_PASS:-dw_pass}
PG_DB_NAME=${PG_DB_NAME:-dw}

# 1. Captura os argumentos
PROJECT_NAME=$1
USER_NAME=$2
USER_PASS=$3

# 2. Validação de argumentos
if [ -z "$PROJECT_NAME" ] || [ -z "$USER_NAME" ] || [ -z "$USER_PASS" ]; then
  echo "❌ Uso incorreto!"
  echo "👉 Exemplo: bash scripts/create_project_db.sh retail retail_user retail_pass"
  exit 1
fi

# 3. Define o nome do novo banco de dados
DB_NAME="db_${PROJECT_NAME}"

echo "🚀 Criando banco e usuário para o projeto: $PROJECT_NAME"
echo "   Banco: $DB_NAME"
echo "   Usuário: $USER_NAME"

# 4. Define o comando SQL a ser executado
SQL_COMMANDS="
CREATE DATABASE ${DB_NAME};
CREATE USER ${USER_NAME} WITH ENCRYPTED PASSWORD '${USER_PASS}';
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${USER_NAME};
"

# 5. Detectar e executar o comando no ambiente correto (Docker ou K8s)
# 5.1. Ambiente Docker
if docker ps --format '{{.Names}}' | grep -q "postgres"; then
  echo "🐳 Ambiente Docker detectado."
  # Executa o comando SQL no container 'postgres' usando as credenciais de admin
  docker exec -i postgres psql -U $PG_ADMIN_USER -d $PG_DB_NAME <<< "$SQL_COMMANDS"

# 5.2. Ambiente Kubernetes (Kind)
elif kubectl get pods -n data 2>/dev/null | grep -q "postgres"; then
  echo "☸️ Ambiente Kubernetes detectado."
  # Encontra o nome do Pod do PostgreSQL no namespace 'data'
  POD=$(kubectl get pods -n data -l app.kubernetes.io/name=postgresql -o jsonpath="{.items[0].metadata.name}")
  
  if [ -z "$POD" ]; then
    echo "❌ Pod do PostgreSQL não encontrado no namespace 'data'."
    exit 1
  fi

  # Executa o comando SQL no Pod do PostgreSQL
  kubectl exec -i $POD -n data -- psql -U $PG_ADMIN_USER -d $PG_DB_NAME <<< "$SQL_COMMANDS"

else
  echo "❌ Nenhum container/pod do Postgres encontrado! Certifique-se de que o ambiente (Docker Compose ou K8s) está ativo."
  exit 1
fi

# 6. Saída de sucesso
if [ $? -eq 0 ]; then
  echo "✅ Banco e usuário criados com sucesso!"
  echo "🔗 String de conexão (Docker Compose):"
  echo "   postgresql://${USER_NAME}:${USER_PASS}@postgres:5432/${DB_NAME}"
  echo "🔗 String de conexão (Kubernetes):"
  echo "   postgresql://${USER_NAME}:${USER_PASS}@postgres.data.svc.cluster.local:5432/${DB_NAME}"
else
  echo "❌ Erro ao executar comandos SQL. Verifique as credenciais e o status do PostgreSQL."
fi
