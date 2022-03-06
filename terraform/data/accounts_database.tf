resource "elephantsql_instance" "lostcities_accounts_database" {
  name   = "lostcities_accounts"
  plan   = "turtle"
  region = "amazon-web-services::us-east-1"
}

resource "google_secret_manager_secret" "accounts_database_url" {
  secret_id = "accounts_database_url"

  replication {
    user_managed {
      replicas {
          location = "us-east1"
      }
    }
  }
}

output "unsensitive_1" {
  value = nonsensitive(jsonencode(elephantsql_instance.lostcities_accounts_database))
}


variable "accounts_database_regex_value" { 
  default = {}
}

variable "accounts_database_url_value" {
  type = string
  default = null
}

variable "accounts_database_user_value" {
  type = string
  default = null
}

variable "accounts_database_password_value" {
  type = string
  default = null
}

locals {
  accounts_database_regex_value = regex("postgres://(?P<user>[A-z]*):(?P<password>[A-z0-9]*)@(?P<host>.*)/", elephantsql_instance.lostcities_accounts_database.url)

  accounts_database_user_value = var.accounts_database_regex_value["user"]

  accounts_database_password_value = var.accounts_database_regex_value["password"]

  accounts_database_url_value = "jdbc:postgresql://${var.accounts_database_regex_value["host"]}/${var.accounts_database_user_value}"
}

resource "google_secret_manager_secret_version" "accounts_database_url_version" {
  secret = google_secret_manager_secret.accounts_database_url.id

  secret_data = var.accounts_database_url_value
}


resource "google_secret_manager_secret" "accounts_database_user" {
  secret_id = "accounts_database_user"

  replication {
    user_managed {
      replicas {
          location = "us-east1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "accounts_database_user_version" {
  secret = google_secret_manager_secret.accounts_database_user.id

  secret_data = var.accounts_database_user_value
}

resource "google_secret_manager_secret" "accounts_database_password" {
  secret_id = "accounts_database_password"

  replication {
    user_managed {
      replicas {
          location = "us-east1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "accounts_database_password_version" {
  secret = google_secret_manager_secret.accounts_database_password.id
  secret_data = var.accounts_database_password_value
}