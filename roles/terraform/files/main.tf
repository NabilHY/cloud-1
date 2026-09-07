provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "selected" {
  id = "vpc-0f383d92a34d3fa17"
}

data "aws_subnet" "selected" {
  id = "subnet-03d84bdc3c69c23b1"
}

data "aws_security_group" "selected" {
  id = "sg-039b04d34a24ef144"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.cloud-1.id
  allocation_id = "eipalloc-0b6b6ff268e0c25d1"
}

resource "aws_instance" "cloud-1" {
  ami           = "ami-0b6d9d3d33ba97d99"
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnet.selected.id
  key_name      = "cloud-1"

  vpc_security_group_ids = [
    data.aws_security_group.selected.id
  ]

  tags = {
    Name = "cloud-1"
  }
}

