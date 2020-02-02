module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.51.0"

  name = "mntc-minecraft"

  cidr = "10.0.100.0/25"

  azs             = ["us-east-2a"]
  private_subnets = ["10.0.100.0/26"]
  public_subnets  = ["10.0.100.64/26"]

  assign_generated_ipv6_cidr_block = false

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "mntc-minecraft"
  }

  tags = {
    Owner       = "mntc"
    Environment = "demo"
  }

  vpc_tags = {
    Name = "mntc-minecraft"
  }
}

module "ecs" {
  source     = "./modules/ecs"
  vpc_id     = "${module.vpc.vpc_id}"
  public_subnet_ids = ["${module.vpc.public_subnets}"]
}
