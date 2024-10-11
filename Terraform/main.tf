provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_pubsub_topic" "data_ingest" {
  name = "data-ingest-topic"
}

resource "google_pubsub_subscription" "data_ingest_sub" {
  name  = "data-ingest-subscription"
  topic = google_pubsub_topic.data_ingest.name
}

resource "google_bigquery_dataset" "analytics_dataset" {
  dataset_id = "analytics_dataset"
}

resource "google_cloud_run_service" "api_service" {
  name     = "data-api"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.data_api_sa.email
      containers {
        image = "us-east4-docker.pkg.dev/latam-devsecops/latam-devsecops-images/data-api:v5"
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_service_account" "data_api_sa" {
  account_id   = "data-api-sa"
  display_name = "Data API Service Account"
}

resource "google_project_iam_member" "data_api_sa_run" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.data_api_sa.email}"
}

resource "google_cloud_run_service_iam_binding" "api_invoker" {
  service    = google_cloud_run_service.api_service.name
  role       = "roles/run.invoker"
  members    = ["allUsers"]  # Cambiar a allUsers para permitir acceso público
}

# Asignar permisos de BigQuery a la cuenta de servicio
resource "google_project_iam_member" "data_api_sa_bq_user" {
  project = var.project_id
  role    = "roles/bigquery.user" # Permiso para crear trabajos de consulta en BigQuery
  member  = "serviceAccount:${google_service_account.data_api_sa.email}"
}

resource "google_project_iam_member" "data_api_sa_bq_viewer" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer" # Permiso para visualizar los datos en BigQuery
  member  = "serviceAccount:${google_service_account.data_api_sa.email}"
}
