resource "aws_s3_bucket" "athena_results_bucket" {
  bucket = "${var.project_name}-athena-results"
}

resource "aws_athena_database" "database" {
  name   = var.project_name
  bucket = aws_s3_bucket.athena_results_bucket.bucket
}

resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
  name          = "sensors_raw"
  database_name = aws_athena_database.database.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL                            = "TRUE"
    "projection.datehour.type"          = "date"
    "projection.datehour.range"         = "2021/01/01/00,NOW"
    "projection.datehour.format"        = "yyyy/MM/dd/HH"
    "projection.datehour.interval"      = 1
    "projection.datehour.interval.unit" = "HOURS"
    "projection.enabled"                = "true"
    "storage.location.template"         = "s3://${aws_s3_bucket.bucket.bucket}/$${datehour}/"

  }


  partition_keys {
    name = "datehour"
    type = "string"
  }

  storage_descriptor {
    location      = "s3://my-bucket/event-streams/my-stream"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "my-stream"
      serialization_library = "org.apache.hive.hcatalog.data.JsonSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }

    columns {
      name = "device"
      type = "string"
    }
    columns {
      name = "voltage"
      type = "float"
    }
    columns {
      name = "temp"
      type = "float"
    }
    columns {
      name = "pressure"
      type = "float"
    }
    columns {
      name = "humidity"
      type = "float"
    }
    columns {
      name = "ts"
      type = "timestamp"
    }
  }


}

output "athena_result_bucket" {
  value = aws_s3_bucket.athena_results_bucket.bucket
}
