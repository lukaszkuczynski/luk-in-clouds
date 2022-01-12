resource "aws_iot_topic_rule" "rule" {
  name        = "all_ESP_readings"
  description = "All readings from sensor"
  enabled     = true
  sql         = "SELECT * FROM 'lukmqtt/#'"
  sql_version = "2016-03-23"

  firehose {
    delivery_stream_name = aws_kinesis_firehose_delivery_stream.extended_s3_stream.name
    role_arn             = aws_iam_role.kinesis_write_role.arn
    separator            = "\n"
  }
}

resource "aws_iam_role" "kinesis_write_role" {
  name = "kinesis_write_role_esp"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "iot.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "kinesis_putrecord_policy" {
  name   = "kinesis_put_policy"
  role   = aws_iam_role.kinesis_write_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": [
            "firehose:DescribeDeliveryStream",
            "firehose:PutRecord",
            "firehose:PutRecordBatch"
        ],        
        "Resource": "${aws_kinesis_firehose_delivery_stream.extended_s3_stream.arn}"
    }
}
  EOF
}

