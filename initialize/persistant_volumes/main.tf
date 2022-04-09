
terraform {

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }

  }
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




provider "digitalocean" {
  token = data.vault_generic_secret.vault_secrets.data["digitalocean_key"]
}

