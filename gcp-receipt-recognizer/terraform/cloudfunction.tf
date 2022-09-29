resource "google_storage_bucket" "bucket" {
  # name     = "gcp-receipt-luk-${terraform.workspace}"
  name     = "gcp-receipt-luk-1231"
  location = "EUROPE-CENTRAL2"
}

resource "google_storage_bucket" "uploads_bucket" {
  name     = "gcp-receipt-luk-1231-uploads"
  location = "EUROPE-CENTRAL2"
}

resource "google_storage_bucket_object" "upload_function_zip" {
  name   = "uploadfunction.zip"
  bucket = google_storage_bucket.bucket.name
  source = "../uploadfunction.zip"
}



resource "google_cloudfunctions_function" "upload_function" {
  name        = "upload-function-${terraform.workspace}"
  description = "Upload function"
  runtime     = "python37"

  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.upload_function_zip.name
  trigger_http          = true
  entry_point           = "entrypoint"

  
  environment_variables = {
    BUCKET_NAME      = google_storage_bucket.uploads_bucket.name
  }
}


# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.upload_function.project
  region         = google_cloudfunctions_function.upload_function.region
  cloud_function = google_cloudfunctions_function.upload_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
