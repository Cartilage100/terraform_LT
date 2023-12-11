# ------------
# vpc
# ------------
resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
    tags = local.tags
}

# ------------
# subnet
# ------------
resource "aws_subnet" "name" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.1.0/24"
    tags = local.tags
}

# ------------
# IGW
# ------------
resource "aws_internet_gateway" "name" {
  vpc_id = aws_vpc.name.id
  tags = local.tags
}

# ------------
# Route table
# ------------
resource "aws_route_table" "name" {
  vpc_id = aws_vpc.name.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.name.id
  }
  tags = local.tags
}

resource "aws_route_table_association" "name" {
  subnet_id = aws_subnet.name.id
  route_table_id = aws_route_table.name.id
}

# ------------
# SG
# ------------
resource "aws_security_group" "name" {
  name = "tf-test-sg"
  description = "for ec2 linux-test"
  vpc_id = aws_vpc.name.id
  tags = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_in" {
  security_group_id = aws_security_group.name.id
  ip_protocol = "tcp"
  from_port = 80
  to_port = 80
  cidr_ipv4 = aws_vpc.name.cidr_block

  tags = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_in" {
  security_group_id = aws_security_group.name.id
  ip_protocol = "tcp"
  from_port = 443
  to_port = 443
  cidr_ipv4 = aws_vpc.name.cidr_block

  tags = local.tags
}

resource "aws_vpc_security_group_egress_rule" "name" {
  security_group_id = aws_security_group.name.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"

  tags = local.tags
}

# ------------
# EC2
# ------------
# https://qiita.com/to-fmak/items/7623ee6e15249a4bcedd
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "ec2_1" {
  ami = data.aws_ami.amzlinux2.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.name.id

# 一度指定したamiを変更しない
  lifecycle { 
    ignore_changes = [ 
        ami,
     ]
  }
  tags = local.tags
}

resource "aws_instance" "ec2_2" {
  ami = data.aws_ami.amzlinux2.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.name.id

  lifecycle {
    ignore_changes = [ 
        ami,
     ]
  }
  tags = local.tags
}