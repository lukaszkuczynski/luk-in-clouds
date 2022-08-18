data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "athena_results" {
  bucket = "${var.project_name}-${data.aws_caller_identity.current.account_id}-athena-results"
}

resource "aws_athena_database" "database" {
  name   = "${var.project_name}"
  bucket = aws_s3_bucket.athena_results.bucket
}

resource "aws_athena_workgroup" "athena_workgroup" {
  name = "${var.project_name}-workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/output/"
    }
  }
}

resource "aws_s3_bucket" "raw_data_bucket" {
  bucket = "${var.project_name}-data-raw-${data.aws_caller_identity.current.account_id}"
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
            "arn:aws:s3:::${aws_s3_bucket.raw_data_bucket.bucket}",
            "arn:aws:s3:::${aws_s3_bucket.raw_data_bucket.bucket}/*"
        ]
    }
}
EOF
}

resource "aws_iam_role_policy_attachment" "glue_attachment_glue" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  role       = aws_iam_role.glue_role.id
}
