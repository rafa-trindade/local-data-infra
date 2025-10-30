# 🧩 local-data-infra `em desenvolvimento`

Infraestrutura modular, reprodutível e portátil para projetos de dados em ambiente local, construída com Terraform, Docker e Kubernetes (Helm).

## ⚙️ Stack Principal
- **Airflow** → Orquestração de pipelines
- **DBT** → Transformações SQL e modelagem
- **PostgreSQL 16** → Data Warehouse relacional
- **Terraform + Kind** → Cluster Kubernetes local
- **Helm + Helmfile** → Gerenciamento modular dos serviços
