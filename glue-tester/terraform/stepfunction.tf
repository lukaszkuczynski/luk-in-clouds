data "aws_region" "current" {}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "${var.project_name}-state-machine"
  role_arn = aws_iam_role.state_machine_role.arn

  definition = <<EOF
{
  "Comment": "call athena",
  "StartAt": "Start an Athena query",
  "States": {
    "Start an Athena query": {
        "Type": "Task",
        "Resource": "arn:aws:states:::athena:startQueryExecution.sync",
        "Parameters": {
            "QueryString": "SELECT * FROM \"gluetester\".\"zip\" limit 10",
            "WorkGroup": "gluetester-workgroup"
        },
        "Next": "Get Results",
      "OutputPath": "$.QueryExecution"
    },
    "Get Results": {
      "Type": "Task",
      "Resource": "arn:aws:states:::athena:getQueryExecution",
      "Parameters": {
        "QueryExecutionId": "$.QueryExecutionId"
      },
      "End": true
    }
  }
}
EOF
}



resource "aws_iam_role" "state_machine_role" {
  name = "state_machine_${var.project_name}"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "states.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "stepfunctions_attachment_step" {
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
  role       = aws_iam_role.state_machine_role.id
}

resource "aws_iam_role_policy" "sf_policies" {
  role   = aws_iam_role.state_machine_role.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "athena:GetQueryExecution",
        "athena:GetQueryResults",
        "athena:StartQueryExecution"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:athena:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:workgroup/${aws_athena_workgroup.athena_workgroup.name}"
    },
    {
      "Action": [
        "glue:GetTable",
        "glue:GetPartitions"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "s3:ListBucket",
          "s3:*Object"
      ],
      "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.raw_data_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.raw_data_bucket.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.athena_results.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.athena_results.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.athena_results.bucket}/output/*"
      ]
    }
  ]
}
EOF
}

