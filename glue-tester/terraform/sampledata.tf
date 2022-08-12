

resource "aws_glue_crawler" "example" {
  database_name = aws_athena_database.database.name
  name          = "${var.project_name}_csv_crawler"
  role          = aws_iam_role.crawler_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.raw_data_bucket.bucket}/zip/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
  }

  configuration = <<EOF
{
  "Version":1.0,
  "Grouping": {
  }
}
EOF
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.crawler_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:*Object"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.raw_data_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.raw_data_bucket.bucket}/*",
        ]
      }
    ]
  })
}


resource "aws_iam_role" "crawler_role" {
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

resource "aws_iam_role_policy_attachment" "crawler_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  role       = aws_iam_role.crawler_role.id
}

output "crawler_name" {
  value = aws_glue_crawler.example.name
}
