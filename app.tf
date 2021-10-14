# resource "google_app_engine_application" "hello-world-idme" {
#   name        = "hello-world-idme"
#   project     = data.google_project.IDME.project_id
#   location_id = "us-east1"
# }

resource "google_app_engine_flexible_app_version" "hello-world-v1" {
  version_id = "v1"
  service    = "hello-world"
  runtime    = "python"
  project    = google_project_iam_member.hw-api.project

  entrypoint {
    shell = "gunicorn -b :$PORT main:app"
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.app-bucket.name}/${google_storage_bucket_object.hello-world-source.name}"
    }
  }

  liveness_check {
    path = "/health"
  }

  readiness_check {
    path = "/health"
  }

  env_variables = {
    DB_USER     = google_sql_user.db-user.name
    DB_PASSWORD = google_sql_user.db-user.password
    DB_HOST     = "172.17.0.1"
  }

  beta_settings = {
    cloud_sql_instances = "${google_sql_database_instance.hello-world-db-instance.connection_name}=tcp:5432"
  }

  handlers {
    url_regex        = "/static/(.*)"
    auth_fail_action = "AUTH_FAIL_ACTION_REDIRECT"
    login            = "LOGIN_OPTIONAL"
    security_level   = "SECURE_OPTIONAL"
    static_files {
      path              = "static/\\1"
      upload_path_regex = "static/.*"
    }
  }

  automatic_scaling {
    cpu_utilization {
      target_utilization = 0.8
    }
  }
}
