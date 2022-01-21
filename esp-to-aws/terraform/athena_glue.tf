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
    EXTERNAL                    = "TRUE"
    "storage.location.template" = "s3://${aws_s3_bucket.bucket.bucket}/"

  }


  partition_keys {
    name = "year"
    type = "int"
  }
  partition_keys {
    name = "month"
    type = "int"
  }
  partition_keys {
    name = "day"
    type = "int"
  }
  partition_keys {
    name = "hour"
    type = "int"
  }



  storage_descriptor {
    location      = "s3://${aws_s3_bucket.bucket.bucket}/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "my-stream"
      serialization_library = "org.apache.hive.hcatalog.data.JsonSerDe"

      parameters = {
        "serialization.format"  = 1
        "ignore.malformed.json" = "true"
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
