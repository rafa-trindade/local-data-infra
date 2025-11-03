# 🧩 local-data-infra

`repositório de estudo e testes de IaC`

`em desenvolvimento`

Infraestrutura modular, reprodutível e portátil para projetos de dados em ambiente local, construída com Terraform, Docker e Kubernetes (Helm).


## ⚙️ Stack Principal
- **Airflow** → Orquestração de pipelines
- **DBT** → Transformações SQL e modelagem
- **PostgreSQL 16** → Data Warehouse relacional
- **Terraform + Kind** → Cluster Kubernetes local
- **Helm + Helmfile** → Gerenciamento modular dos serviços

---

## 🚀 Guia de Inicialização

### Pré-requisitos

Certifique-se de ter as seguintes ferramentas instaladas:
- [Docker](https://docs.docker.com/get-docker/) e [Docker Compose](https://docs.docker.com/compose/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Terraform](https://www.terraform.io/downloads)
- [Helm](https://helm.sh/docs/intro/install/) e [Helmfile](https://helmfile.readthedocs.io/en/latest/#installation)

### ⚙️ 1️⃣ Subir ambiente Kubernetes (Kind)

Este passo cria um cluster Kubernetes local chamado `data-platform` usando o Kind.

```bash
# 1. Navegue para o diretório do Terraform
cd infra/terraform

# 2. Inicialize o Terraform
terraform init

# 3. Aplique a configuração para criar o cluster Kind
terraform apply -auto-approve
```

### ⚙️ 2️⃣ Implantar os serviços (Helmfile)

Com o cluster Kind ativo, implante os serviços de dados (Postgres, Airflow, DBT) no namespace `data`.

```bash
# 1. Retorne para o diretório raiz do projeto
cd ../..

# 2. Implante os serviços usando Helmfile
# O Helmfile garantirá que o namespace 'data' seja criado e que o Postgres suba antes do Airflow.
helmfile -f infra/k8s/helmfile.yaml apply
```

**Acessos (Kubernetes):**
- **Airflow UI:** `http://localhost:30080` (Usuário: `airflow`, Senha: `airflow`)
- **Postgres:** Acesso interno ao cluster via `postgres.data.svc.cluster.local:5432`

### ⚙️ 3️⃣ Criar banco para novo projeto

Cada projeto que usar essa infra terá **seu próprio banco e usuário** dentro do mesmo Postgres.

Use o script `create_project_db.sh`, que funciona tanto para o ambiente Docker Compose quanto para o Kubernetes.

```bash
bash scripts/create_project_db.sh <nome_projeto> <usuario> <senha>
```

Exemplo:
```bash
bash scripts/create_project_db.sh retail retail_user retail_pass
```

Saída esperada:
```arduino
🚀 Criando banco e usuário para o projeto: retail
🐳 Ambiente Docker detectado. (ou ☸️ Ambiente Kubernetes detectado.)
✅ Banco e usuário criados com sucesso!
🔗 String de conexão (Docker Compose):
   postgresql://retail_user:retail_pass@postgres:5432/db_retail
🔗 String de conexão (Kubernetes):
   postgresql://retail_user:retail_pass@postgres.data.svc.cluster.local:5432/db_retail
```

### ⚙️ 4️⃣ Uso com outros repositórios (DBT)

Para usar o DBT em um repositório externo (`retail-pipeline`), configure o arquivo `profiles.yml` com a string de conexão Kubernetes.

Consulte o arquivo de exemplo `dbt_project/profiles.yml.example` para a configuração correta.

### ⚙️ 5️⃣ Rodar ambiente local via Docker Compose (Alternativa)

Para um ambiente de desenvolvimento mais leve, sem a necessidade do Kubernetes, use o Docker Compose.

```bash
# 1. Retorne para o diretório raiz do projeto
cd infra/terraform/..

# 2. Suba os serviços em background
docker-compose -f docker/docker-compose.yaml up -d
```

**Acessos (Docker Compose):**
- **Airflow UI:** `http://localhost:8080` (Usuário: `airflow`, Senha: `airflow`)
- **Postgres:** `localhost:5432` (user: `dw_user`, pass: `dw_pass`)

### ⚙️ 6️⃣ Limpeza

Para derrubar os ambientes:

**Kubernetes (Kind):**
```bash
cd infra/terraform
terraform destroy -auto-approve
```

**Docker Compose:**
```bash
docker-compose -f docker/docker-compose.yaml down -v
```