resource "elephantsql_instance" "lostcities_matches_database" {
  name   = "lostcities_matches"
  plan   = "turtle"
  region = "amazon-web-services::us-east-1"
}

resource "google_secret_manager_secret" "matches_database_url" {
  secret_id = "matches_database_url"

  replication {
    user_managed {
      replicas {
          location = "us-east1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "matches_database_url_version" {
  secret = google_secret_manager_secret.matches_database_url.id

  secret_data = replace(elephantsql_instance.lostcities_matches_database.url, "postgres://(?P<user>[A-z]*):(?P<password>[A-z0-9]*)@(?P<host>.*)/", "jdbc:postgresql://$host/$user")
}


resource "google_secret_manager_secret" "matches_database_user" {
  secret_id = "matches_database_user"

  replication {
    user_managed {
      replicas {
          location = "us-east1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "matches_database_user_version" {
  secret = google_secret_manager_secret.matches_database_user.id

  secret_data = regex("postgres://(?P<user>[A-z]*):(?P<password>[A-z0-9]*)@(?P<host>.*)/", elephantsql_instance.lostcities_matches_database.url)["user"]
}

resource "google_secret_manager_secret" "matches_database_password" {
  secret_id = "matches_database_password"

  replication {
    user_managed {
      replicas {
          location = "us-east1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "matches_database_password_version" {
  secret = google_secret_manager_secret.matches_database_password.id

  secret_data = regex("postgres://(?P<user>[A-z]*):(?P<password>[A-z0-9]*)@(?P<host>.*)/", elephantsql_instance.lostcities_matches_database.url)["password"]
}