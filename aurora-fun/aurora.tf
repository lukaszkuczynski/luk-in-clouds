data "aws_availability_zones" "available" {}

resource "aws_rds_cluster" "default" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora"
  engine_version          = "5.6.mysql_aurora.1.23.4"
  availability_zones      = data.aws_availability_zones.available.names
  database_name           = "auroramysqldb"
  master_username         = "foo"
  master_password         = "barbarbar"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.allow_mysql.id]

  db_subnet_group_name            = aws_db_subnet_group.default.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.default.name

  iam_roles = [aws_iam_role.iam_for_aurora.arn]

}

resource "aws_db_subnet_group" "default" {
  name       = "db-subnet-aurora"
  subnet_ids = module.vpc.public_subnets
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count               = 2
  identifier          = "aurora-cluster-demo-${count.index}"
  cluster_identifier  = aws_rds_cluster.default.id
  instance_class      = "db.t2.small"
  engine              = aws_rds_cluster.default.engine
  engine_version      = aws_rds_cluster.default.engine_version
  publicly_accessible = true

}

resource "aws_security_group" "allow_mysql" {
  name   = "allow_mysql"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "mysql port"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "mysql port"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "2.77.0"
  name                 = "vpc-aurora"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_iam_role" "iam_for_aurora" {
  name = "iam_for_aurora"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "rds.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_rds_cluster_parameter_group" "default" {
  name        = "rds-cluster-pg"
  family      = "aurora5.6"
  description = "RDS default cluster parameter group"

  parameter {
    name  = "aws_default_lambda_role"
    value = aws_iam_role.iam_for_aurora.arn
  }


}


resource "aws_iam_role_policy" "execute_lambda_for_aurora_policy" {
  name   = "execute_lambda_for_aurora_policy"
  role   = aws_iam_role.iam_for_aurora.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAuroraToExampleFunction",
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": "${aws_lambda_function.aurora_test.arn}"
        }
    ]
}
  EOF
}


resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda_aurora"

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

resource "aws_lambda_function" "aurora_test" {
  filename      = "./lambda_aurora_test.zip"
  function_name = "lambda_aurora_test"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  timeout       = 180

  source_code_hash = filebase64sha256("./lambda_aurora_test.zip")

  runtime = "python3.8"
}
