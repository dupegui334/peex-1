#AWS resources for networking

data "aws_availability_zones" "az" {}

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block

    tags = {
        Name = "PeEx VPC"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main.id
    count = length(var.public_subnet_cidr_block)
    cidr_block = var.public_subnet_cidr_block[count.index]
    availability_zone = data.aws_availability_zones.az.names[count.index]

    tags = {
        Name = "public_subnet-${data.aws_availability_zones.az.names[count.index]}"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "igw main"
    }
}

resource "aws_route_table" "route_table_public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "public_route_table"
    }
}

resource "aws_route_table_association" "public" { #Associate to route table every subnet
  count          = length(var.public_subnet_cidr_block)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.route_table_public.id
}