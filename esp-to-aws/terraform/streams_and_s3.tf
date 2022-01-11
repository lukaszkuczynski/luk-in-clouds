resource "aws_s3_bucket" "bucket" {
  bucket = "${var.project_name}-data"
  acl    = "private"
}

resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "${var.project_name}-delivery-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    buffer_size     = 1
    buffer_interval = 60
    role_arn        = aws_iam_role.firehose_role.arn
    bucket_arn      = aws_s3_bucket.bucket.arn
  }
}

resource "aws_iam_role" "firehose_role" {
  name = "firehose_test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda_iam" {
  name = "lambda_iam"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
