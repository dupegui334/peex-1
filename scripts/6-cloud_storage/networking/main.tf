#AWS resources for networking

data "aws_availability_zones" "az" {}

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block

    tags = {
        Name = "vnet-nebo"
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

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.main.id
    count = length(var.private_subnet_cidr_block)
    cidr_block = var.private_subnet_cidr_block[count.index]
    availability_zone = data.aws_availability_zones.az.names[count.index + 1] #Added +1 to allocate the subnets in differents AZs

    tags = {
        Name = "private_subnet-${data.aws_availability_zones.az.names[count.index + 1]}"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "igw main"
    }
}

# # Elastic IP for NAT Gateway
# resource "aws_eip" "nat_eip" {
#     domain        = "vpc"
#     depends_on = [aws_internet_gateway.igw]
# }

# resource "aws_nat_gateway" "nat_gw" {
#     allocation_id = aws_eip.nat_eip.id
#     subnet_id     = element(aws_subnet.public_subnet.*.id, 0) # NAT attached to first public subnet
#     depends_on = [ aws_internet_gateway.igw ]

#     tags = {
#       Name = "NAT Gateway main PeEx"
#     }
# }

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

resource "aws_route_table" "route_table_private" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "private_route_table"
    }
}

resource "aws_route" "s3_endpoint_route" {
    route_table_id = aws_route_table.route_table_private.id
    destination_cidr_block = "0.0.0.0/0" # Enroutes all traffic throught VPC endpoint

    vpc_endpoint_id = aws_vpc_endpoint.s3.id
  
}

resource "aws_route_table_association" "public" { #Associate route table to public subnet
  count          = length(var.public_subnet_cidr_block)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr_block)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.route_table_private.id

  #depends_on = [ aws_route_table.route_table_private ] # Need to create first the table before making association
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${var.aws-region}.s3"
  route_table_ids = ["${aws_route_table.route_table_private.id}"]

  tags = {
    Name = "my-s3-endpoint"
  }
}

# resource "aws_vpc_endpoint_route_table_association" "route_table_association" {
#   route_table_id = aws_route_table.route_table_public.id
#   vpc_endpoint_id = aws_vpc_endpoint.s3.id
# }