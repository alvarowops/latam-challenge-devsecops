provider "google" {
  project = var.project_id
  region  = var.region
}

# Pub/Sub Topic para ingesta de datos
resource "google_pubsub_topic" "data_ingest" {
  name = "data-ingest-topic"
}

# Suscripción a Pub/Sub
resource "google_pubsub_subscription" "data_ingest_sub" {
  name  = "data-ingest-subscription"
  topic = google_pubsub_topic.data_ingest.name
}

# Dataset en BigQuery para almacenar los datos
resource "google_bigquery_dataset" "analytics_dataset" {
  dataset_id = "analytics_dataset"
}

# Tabla en BigQuery para almacenar los datos
resource "google_bigquery_table" "example_table" {
  dataset_id = google_bigquery_dataset.analytics_dataset.dataset_id
  table_id   = "example_table"

  schema = jsonencode([
    {
      name = "id"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "name"
      type = "STRING"
      mode = "NULLABLE"
    }
  ])
}

# Cloud Run Service para exponer los datos
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

# Cuenta de servicio para la API
resource "google_service_account" "data_api_sa" {
  account_id   = "data-api-sa"
  display_name = "Data API Service Account"
}

# Permisos para ejecutar Cloud Run
resource "google_project_iam_member" "data_api_sa_run" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.data_api_sa.email}"
}

# Permiso para permitir el acceso público a la API
resource "google_cloud_run_service_iam_binding" "api_invoker" {
  service = google_cloud_run_service.api_service.name
  role    = "roles/run.invoker"
  members = ["allUsers"]
}

# Permisos para BigQuery para la API
resource "google_project_iam_member" "data_api_sa_bq_user" {
  project = var.project_id
  role    = "roles/bigquery.user"
  member  = "serviceAccount:${google_service_account.data_api_sa.email}"
}

resource "google_project_iam_member" "data_api_sa_bq_viewer" {
  project = var.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:${google_service_account.data_api_sa.email}"
}

# Cuenta de servicio para la Cloud Function
resource "google_service_account" "function_sa" {
  account_id   = "function-sa"
  display_name = "Function Service Account"
}

# Permisos para la cuenta de servicio de la función para acceder a Pub/Sub y BigQuery
resource "google_project_iam_member" "function_sa_pubsub_sub" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

resource "google_project_iam_member" "function_sa_bq_writer" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# Bucket para almacenar el código fuente de la función
resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}-functions"
  location = var.region
}

# Objeto en el bucket con el código fuente de la función
resource "google_storage_bucket_object" "function_source" {
  name   = "pubsub_to_bigquery.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "pubsub_to_bigquery.zip" # Ruta al archivo con el código fuente comprimido
}

# Cloud Function para procesar datos desde Pub/Sub a BigQuery
resource "google_cloudfunctions_function" "pubsub_to_bigquery" {
  name                  = "pubsub-to-bigquery"
  description           = "Ingesta datos desde Pub/Sub a BigQuery"
  runtime               = "python39"
  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_source.name
  entry_point           = "ingest_data"
  service_account_email = google_service_account.function_sa.email

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.data_ingest.id
  }

  environment_variables = {
    PROJECT_ID = var.project_id
    DATASET    = google_bigquery_dataset.analytics_dataset.dataset_id
    TABLE_NAME = google_bigquery_table.example_table.table_id
  }
}
