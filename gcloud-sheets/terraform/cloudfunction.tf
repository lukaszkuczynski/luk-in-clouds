resource "google_storage_bucket" "bucket" {
  name     = "wroeng-schedule-${terraform.workspace}"
  location = "EUROPE-CENTRAL2"
}

resource "google_storage_bucket_object" "archive" {
  name   = "schedule_welcome.zip"
  bucket = google_storage_bucket.bucket.name
  source = "../schedule_welcome.zip"
}

resource "google_storage_bucket_object" "mail_sender_archive" {
  name   = "mail_sender_archive.zip"
  bucket = google_storage_bucket.bucket.name
  source = "../mail_sender_archive.zip"
}

resource "google_cloudfunctions_function" "welcome_page_function" {
  name        = "schedule-welcome-page-${terraform.workspace}"
  description = "Welcome page function"
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
    SPREADSHEET_ID      = var.spreadsheet_id
    SHEET_RANGE         = var.sheet_range
    INDEX_NAME          = var.index_name
    SENDER_FUNCTION_URL = google_cloudfunctions_function.mail_sender_function.https_trigger_url
  }
}

resource "google_cloudfunctions_function" "mail_sender_function" {
  name        = "schedule-mail-sender-${terraform.workspace}"
  description = "Mail sender function"
  runtime     = "python39"

  available_memory_mb   = 512
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.mail_sender_archive.name
  trigger_http          = true
  entry_point           = "entrypoint"

  environment_variables = {
    INDEX_NAME       = var.index_name
    MAIL_FROM        = var.mail_from
    SENDGRID_API_KEY = var.sendgrid_api_key
    REPLY_TO_NAME    = var.reply_to_name
    REPLY_TO_EMAIL   = var.reply_to_email
  }
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.welcome_page_function.project
  region         = google_cloudfunctions_function.welcome_page_function.region
  cloud_function = google_cloudfunctions_function.welcome_page_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "invoker2" {
  project        = google_cloudfunctions_function.mail_sender_function.project
  region         = google_cloudfunctions_function.mail_sender_function.region
  cloud_function = google_cloudfunctions_function.mail_sender_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
