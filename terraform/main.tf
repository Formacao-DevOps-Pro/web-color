terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.28.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.11.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "homolog" {
  depends_on = [local_file.this]
  metadata {
    name = "homolog"
  }
}

resource "kubernetes_namespace" "producao" {
  depends_on = [local_file.this]
  metadata {
    name = "prod"
  }
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = "devops4devs"
  kubernetes_version  = "1.27.9"

  default_node_pool {
    name       = "default"
    node_count = var.default_node_pool_count
    vm_size    = var.default_node_pool_size
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "local_file" "this" {
  content  = azurerm_kubernetes_cluster.this.kube_config_raw
  filename = "kube_config.yaml"
}

variable "resource_group_name" {
  default = "devops4devs-rg"
}

variable "location" {
  default = "Brazil South"
}

variable "cluster_name" {
  default = "devops4devs-k8s"
}

variable "default_node_pool_count" {
  default = 3
}

variable "default_node_pool_size" {
  default = "Standard_D2_v2"
}