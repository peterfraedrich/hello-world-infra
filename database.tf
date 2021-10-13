resource "google_sql_database" "hello-world-db" {
  name     = "hello-world-db"
  instance = google_sql_database_instance.hello-world-db-instance.name
}

resource "google_sql_database_instance" "hello-world-db-instance" {
  name             = "hello-world-db-instance"
  database_version = "POSTGRES_13"
  region           = "us-east1"
  settings {
    tier = "db-f1-micro"
    insights_config {
      query_insights_enabled = true
    }
  }
}

resource "google_sql_user" "db-user" {
  name     = "postgres"
  instance = google_sql_database_instance.hello-world-db-instance.name
  password = "secretpassword"
}
