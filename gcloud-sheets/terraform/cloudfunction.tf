resource "google_storage_bucket" "bucket" {
  name     = "test-bucket-luk"
  location = "EUROPE-CENTRAL2"
}

resource "google_storage_bucket_object" "archive" {
  name   = "testfun.zip"
  bucket = google_storage_bucket.bucket.name
  source = "../testfun.zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = "function-test"
  description = "My function"
  runtime     = "python39"

  available_memory_mb   = 512
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "entrypoint"

  depends_on = [
    google_storage_bucket_object.archive
  ]

  environment_variables = {
    SPREADSHEET_ID = var.spreadsheet_id
    SHEET_RANGE    = var.sheet_range
    INDEX_NAME     = var.index_name
  }
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
