provider "google" {
  project = var.project_id
}

# storage
resource "google_storage_bucket" "bucket" {
  name     = var.bucket_name
  location = var.region

  lifecycle_rule {
    condition {
      age = var.days_buckups
    }
    action {
      type = "Delete"
    }
  }
}

# service account
resource "google_service_account" "export_user" {
  account_id   = "${var.spanner_instance}-${var.spanner_db}-export"
  display_name = "${var.spanner_instance}-${var.spanner_db}-export"
}
resource "google_project_iam_member" "export_user_dataflow_role" {
  role   = "roles/dataflow.developer"
  member = "serviceAccount:${google_service_account.export_user.email}"
}

# dataflow job
resource "google_cloud_scheduler_job" "export_job" {
  name     = "${var.spanner_instance}-${var.spanner_db}-export-job"
  schedule = var.export_schedule
  region   = var.region

  http_target {
    http_method = "POST"
    uri         = "https://dataflow.googleapis.com/v1b3/projects/${var.project_id}/locations/${var.region}/templates"

    oauth_token {
      service_account_email = google_service_account.export_user.email
    }

    body = base64encode(<<-EOT
    {
      "jobName": "${var.spanner_instance}-${var.spanner_db}-export-job",
      "parameters": {
        "instanceId": "${var.spanner_instance}",
        "databaseId": "${var.spanner_db}",
        "outputDir": "${google_storage_bucket.bucket.url}/"
      },
      "gcsPath": "gs://dataflow-templates/${var.dataflow_template_version}/Cloud_Spanner_to_GCS_Avro",
      "environment": {
        "tempLocation": "${google_storage_bucket.bucket.url}/_staging"
      }
    }
EOT
    )
  }
}
