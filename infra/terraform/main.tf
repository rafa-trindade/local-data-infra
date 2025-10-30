terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.6.0"
    }
  }
}

provider "kind" {}

resource "kind_cluster" "data_platform" {
  name           = "data-platform"
  wait_for_ready = true
  node_image     = "kindest/node:v1.29.0"
}

output "kubeconfig" {
  value = kind_cluster.data_platform.kubeconfig
}
