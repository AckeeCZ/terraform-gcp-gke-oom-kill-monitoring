provider "random" {}

provider "google" {}

provider "google-beta" {}

provider "vault" {}

provider "kubernetes" {}

module "oom_kills_monitoring" {
  source = "../"

  project   = var.project
  namespace = var.namespace

  cluster_ca_certificate = module.gke.cluster_ca_certificate
  cluster_token          = module.gke.access_token
  cluster_endpoint       = module.gke.endpoint

  cluster_name = "cluster-test"
  location     = var.zone
}

module "gke" {
  source            = "git::ssh://git@gitlab.ack.ee/Infra/terraform-gke-vpc.git?ref=v11.11.0"
  cluster_name      = "cluster-test"
  namespace         = var.namespace
  project           = var.project
  location          = var.zone
  vault_secret_path = var.vault_secret_path
  private           = false
  min_nodes         = 1
  max_nodes         = 2
}

variable "environment" {
  default = "development"
}

variable "namespace" {
  default = "development"
}

variable "project" {
}

variable "vault_secret_path" {
}

variable "region" {
  default = "europe-west3"
}

variable "zone" {
  default = "europe-west3-c"
}
