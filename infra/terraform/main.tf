# Define a versão mínima do Terraform e os provedores necessários
terraform {
  required_providers {
    # Provedor Kind para gerenciar clusters Kubernetes locais
    kind = {
      source  = "tehcyx/kind"
      version = "0.6.0"
    }
  }
}

# Configura o provedor Kind
provider "kind" {}

# Cria o cluster Kubernetes local com o Kind
resource "kind_cluster" "data_platform" {
  # Nome do cluster, conforme o README
  name           = "data-platform"
  # Espera até que o cluster esteja pronto
  wait_for_ready = true
  # Imagem do nó do Kubernetes (versão 1.29.0)
  node_image     = "kindest/node:v1.29.0"
}

# Saída do kubeconfig para que o Helm/Helmfile possa se conectar
output "kubeconfig" {
  value = kind_cluster.data_platform.kubeconfig
}
