locals {
  name_prefix = "xinwei"
}

## EC2 Instance
resource "aws_instance" "EBS" {
  ami                    = "ami-04c913012f8977029"
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnets.public.ids[0]
  vpc_security_group_ids      = [aws_security_group.EBS.id]
  associate_public_ip_address = true


  tags = {
    Name = "${local.name_prefix}-EC2"
  }
}

resource "aws_security_group" "EBS" {
  name        = "${local.name_prefix}-sg"
  description = "Allow SSH and HTTPS traffic"
  vpc_id      = data.aws_vpc.selected.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.EBS.id
  cidr_ipv4         = "0.0.0.0/0"  
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_https_traffic_ipv4" {
  security_group_id = aws_security_group.EBS.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_https_traffic_ipv6" {
  security_group_id = aws_security_group.EBS.id
  cidr_ipv6         = "::/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

## EBS Volume
resource "aws_ebs_volume" "xinwei-ebs-volume" {
  availability_zone = aws_instance.EBS.availability_zone
  size              = 1
  type              = "gp3"
  tags = {
    Name = "${local.name_prefix}-EBS-Volume"
  }
}

## Attach EBS Volume
resource "aws_volume_attachment" "xinwei_volume_attach" {
  device_name = "/dev/sdb"
  instance_id = aws_instance.EBS.id
  volume_id   = aws_ebs_volume.xinwei-ebs-volume.id
}
