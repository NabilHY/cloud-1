provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "selected" {
  id = "vpc-060011518b8efd6d0"
}

data "aws_subnet" "selected" {
  id = "subnet-09b623c5ccf8ea008"
}

data "aws_security_group" "selected" {
  id = "sg-05449ab83315bac90"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.ohio-cloud1.id
  allocation_id = "eipalloc-075b6eef33e25da93"
}

resource "aws_instance" "ohio-cloud1" {
  ami           = "ami-0e5497a77ef21b5ac"
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnet.selected.id
  key_name      = "ohio"

  vpc_security_group_ids = [
    data.aws_security_group.selected.id
  ]

  tags = {
    Name = "ohio"
  }
}

