resource "aws_s3_bucket" "bucket_processed" {
  bucket = "${var.project_name}-processed-data"
  acl    = "private"
}

resource "aws_iam_role" "glue_role" {
  name = "AWSGlueServiceRole_${var.project_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "glue_read_write_buckets_policy" {
  name = "glue_read_write_buckets_policy"
  role = aws_iam_role.glue_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": [
            "s3:ListBucket",
            "s3:*Object"
        ],
        "Resource": [
            "arn:aws:s3:::${aws_s3_bucket.bucket_processed.bucket}",
            "arn:aws:s3:::${aws_s3_bucket.bucket_processed.bucket}/*",
            "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}",
            "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"
        ]
    }
}
EOF
}

resource "aws_iam_role_policy_attachment" "glue_attachment_1" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  role       = aws_iam_role.glue_role.id
}

data "template_file" "glue_script" {
  template = file("./glue_script.py")
  vars = {
    database               = aws_athena_database.database.name
    glue_table_raw         = aws_glue_catalog_table.aws_glue_catalog_table.name
    glue_table_processed   = "sensors"
    processed_data_s3_path = "s3://${aws_s3_bucket.bucket_processed.bucket}/"
  }
}

data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "glue_scripts" {
  bucket = "aws-glue-scripts-${data.aws_caller_identity.current.account_id}-${var.region}"
}

resource "aws_s3_bucket_object" "object" {
  bucket  = data.aws_s3_bucket.glue_scripts.bucket
  key     = "glue_script.py"
  content = data.template_file.glue_script.rendered

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  #   etag = filemd5("path/to/file")
}


resource "aws_glue_job" "sensors_json_to_parquet" {
  name              = "sensors_json_to_parquet"
  role_arn          = aws_iam_role.glue_role.arn
  glue_version      = "3.0"
  number_of_workers = 2
  max_retries       = 0
  worker_type       = "G.1X"

  # "--continuous-log-logGroup"          = aws_cloudwatch_log_group.example.name

  default_arguments = {
    "--job-bookmark-option"              = "job-bookmark-disable"
    "--job-language"                     = "python 3"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = "true"
  }

  command {
    script_location = "s3://${aws_s3_bucket_object.object.bucket}/${aws_s3_bucket_object.object.key}"
  }
}

output "glue_job_location" {
  value = aws_glue_job.sensors_json_to_parquet.command[0].script_location
}
