resource "aws_s3_bucket" "bucket" {
  bucket = "${var.project_name}-data"
  acl    = "private"
}

resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "${var.project_name}-delivery-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    buffer_size         = 1
    buffer_interval     = 60
    role_arn            = aws_iam_role.firehose_role.arn
    bucket_arn          = aws_s3_bucket.bucket.arn
    error_output_prefix = "errors/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    prefix              = "year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.enrich_records.arn}:$LATEST"
        }
      }
    }
    cloudwatch_logging_options {
      enabled         = "true"
      log_group_name  = "/aws/kinesisfirehose/${var.project_name}-delivery-stream"
      log_stream_name = "DestinationDelivery"
    }
  }
}

resource "aws_iam_role" "firehose_role" {
  name = "kinesis_firehose_role"

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

resource "aws_iam_role_policy" "firehose_policy" {
  name   = "kinesis_firehose_policy"
  role   = aws_iam_role.firehose_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:eu-central-1:${var.account_id}:*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "${aws_s3_bucket.bucket.arn}",
                "${aws_s3_bucket.bucket.arn}/*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "logs:GetLogEvents",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:log-group:/aws/kinesisfirehose/*:log-stream:*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:PutRetentionPolicy",
                "logs:CreateLogGroup"
            ],
            "Resource": "arn:aws:logs:*:*:log-group:/aws/kinesisfirehose/*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords",
                "kinesis:ListShards"
            ],
            "Resource": "${aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn}"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:GetFunctionConfiguration"
            ],
            "Resource": "${aws_lambda_function.enrich_records.arn}:$LATEST"
        }
    ]
}
  EOF
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda_espproject"

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

resource "aws_iam_role_policy" "enrich_lambda_policy" {
  name   = "kinesis_firehose_policy"
  role   = aws_iam_role.iam_for_lambda.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:eu-central-1:${var.account_id}:*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:eu-central-1:${var.account_id}:log-group:/aws/lambda/*:*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "firehose:DescribeDeliveryStream",
                "firehose:Get*",
                "firehose:DescribeDeliveryStream",
                "firehose:PutRecord",
                "firehose:PutRecordBatch"
            ],    
            "Resource": "${aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn}"
        }
    ]

}
EOF
}

resource "aws_lambda_function" "enrich_records" {
  filename      = "../lambda_enrich_records.zip"
  function_name = "lambda_enrich_records"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  timeout       = 180

  source_code_hash = filebase64sha256("../lambda_enrich_records.zip")

  runtime = "python3.8"
}
