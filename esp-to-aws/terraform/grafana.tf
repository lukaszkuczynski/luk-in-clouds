resource "aws_cloudwatch_log_group" "loggroup" {
  name = "${var.project_name}_ecs_logs"
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.project_name}_ecs_cluster"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.loggroup.name
      }
    }
  }
}


resource "aws_ecs_task_definition" "grafana_service" {
  family = "service"

  requires_compatibilities = ["EXTERNAL", "EC2"]
  network_mode             = "bridge"
  cpu                      = 1000
  memory                   = 1000

  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "grafana/grafana-oss"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.loggroup.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }

      }
    }
  ])
}


data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}


resource "aws_security_group" "allow_grafana" {
  name   = "allow_grafana"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "grafana port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "vpc" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = "172.29.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "172.29.1.0/24"
  availability_zone = "eu-central-1a"
}

resource "aws_route_table" "internet" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.internet.id
}

resource "aws_network_interface" "foo" {
  subnet_id = aws_subnet.my_subnet.id
  #   private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy" "ecs_aws_managed_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_policy_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = data.aws_iam_policy.ecs_aws_managed_policy.arn
}


data "aws_iam_role" "ecsInstanceRole" {
  name = "ecsInstanceRole"
}

resource "aws_iam_instance_profile" "ecs_profile" {
  name = "ecs_profile"
  role = data.aws_iam_role.ecsInstanceRole.name
}

resource "aws_instance" "ecs_instance" {
  ami                         = data.aws_ami.amazon_linux_ecs.id
  associate_public_ip_address = true
  instance_type               = "t2.small"
  # vpc_security_group_ids      = [data.aws_security_group.good_sg.id]
  # subnet_id                   = data.aws_subnet.good_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_grafana.id]
  subnet_id              = aws_subnet.my_subnet.id

  iam_instance_profile = aws_iam_instance_profile.ecs_profile.name
  user_data            = <<EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.cluster.name} >> /etc/ecs/ecs.config;echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;
  EOF
}
# grafana-cli plugins install grafana-athena-datasource

output "ec2_ip" {
  value = aws_instance.ecs_instance.public_ip
}
