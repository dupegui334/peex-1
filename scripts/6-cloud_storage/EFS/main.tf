# Main file that imports the networking and
# compute resources in AWS for the exercise.
module "networking" {
  source                    = "./networking"
  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_cidr_block  = var.public_subnet_cidr_block
}

module "compute" {
  source         = "./compute"
  ami            = var.ami
  instance-type  = var.instance-type
  vpc_id         = module.networking.vpc_id
  public_subnet  = module.networking.public_subnet
}