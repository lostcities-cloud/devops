
terraform {

  required_providers {

    google = {}

    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }

  }
}

variable "env" {
  type = string
  default = "stage"
}

variable "google_region" {
  type = string
  default = "us-east1"
}

variable "VAULT_ADDR" {
  type = string
}

variable "VAULT_TOKEN" {
  type = string
}

provider "vault" {
  address = var.VAULT_ADDR
  token = var.VAULT_TOKEN
}

data "vault_generic_secret" "vault_secrets" {
  path = "kv/test"
}


provider "google" {
  project = "lostcities-cloud"
  credentials = data.vault_generic_secret.vault_secrets.data["google_key"]
  region = var.google_region
}

provider "digitalocean" {
  token = data.vault_generic_secret.vault_secrets.data["digitalocean_key"]
}

data "digitalocean_ssh_key" "default" {
  name = "lostcities"
}

module "lostcities_host" {
  source = "../terraform_modules/host"
}