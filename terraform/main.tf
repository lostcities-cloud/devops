
terraform {

  required_providers {

    google = {}

    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }

    cloudamqp = {
      source = "cloudamqp/cloudamqp"
    }

    upstash = {
      source = "upstash/upstash"
      version = "1.0.0"
    }

    elephantsql = {
      source = "gbauso/elephantsql"
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


provider "elephantsql" {
    apikey = data.vault_generic_secret.vault_secrets.data["elephant_key"]
}

provider "cloudamqp" {
  apikey = data.vault_generic_secret.vault_secrets.data["cloudamqp_key"]
}

provider "upstash" {
  email = data.vault_generic_secret.vault_secrets.data["email"]
  api_key = data.vault_generic_secret.vault_secrets.data["upstash_key"]
}

provider "digitalocean" {
  token = data.vault_generic_secret.vault_secrets.data["digitalocean_key"]
}

resource "digitalocean_ssh_key" "default" {
  name       = "lostcities"
  public_key = data.vault_generic_secret.vault_secrets.data["ssh_key_pub"]
}

