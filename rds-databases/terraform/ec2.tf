data "aws_vpc" "main" {
  default = true
}

resource "aws_security_group_rule" "allow_ssh" {
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  type              = "ingress"
  security_group_id = aws_security_group.allow_tcp_ssh.id
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "outall" {
  type              = "egress"
  security_group_id = aws_security_group.allow_tcp_ssh.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}


resource "aws_security_group" "allow_tcp_ssh" {
  name   = "allow_tcp_ssh"
  vpc_id = data.aws_vpc.main.id
}

data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20211001.1-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_key_pair" "keypair" {
  key_name   = "web_ec2_key.pem"
  public_key = var.public_key
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.linux.id
  instance_type               = "t3.micro"
  security_groups             = [aws_security_group.allow_tcp_ssh.name]
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/bootstrap_ec2.tpl", {
    public_key = var.public_key
  })
  key_name = aws_key_pair.keypair.key_name
}

output "ec2_ip" {
  value = aws_instance.web.public_ip
}



