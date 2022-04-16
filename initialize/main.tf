
terraform {

  required_providers {

    google = {}

    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }

    namecheap = {
      source = "namecheap/namecheap"
      version = ">= 2.0.0"
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

provider "namecheap" {
  user_name = data.vault_generic_secret.vault_secrets.data["namecheap_user_name"]
  api_user = data.vault_generic_secret.vault_secrets.data["namecheap_api_user"]
  api_key = data.vault_generic_secret.vault_secrets.data["namecheap_api_key"]
  use_sandbox = false
}

data "digitalocean_ssh_key" "default" {
  name = "lostcities"
}

data "digitalocean_ssh_key" "jenkins_key" {
  name = "jenkins"
}

