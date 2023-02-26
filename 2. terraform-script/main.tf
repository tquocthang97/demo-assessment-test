# terraform {
#   backend "s3" {
#      bucket = "bucket-name"
#      key = "terraform_vpc.tfstate"
#      region = "us-west-1"
#      encrypt = true
#    }
#  }


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "test-vpc"
  cidr = "172.20.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b"]
  public_subnets = ["172.20.32.0/20", "172.20.16.0/20"]
  private_subnets  = ["172.20.96.0/20", "172.20.48.0/20"]
  
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Terraform = "true"
    Environment = "data"
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.5.1"

  cluster_name    = var.cluster_name
  cluster_version = "1.24"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                      = flatten([module.vpc.private_subnets,module.vpc.public_subnets])
  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    on-demand-instance = {
      name = "on-demand-instance"

      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 3
      desired_size = 2
    }

    spot-instance = {
      name = "spot-instance"

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"
      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }
}


module "aurora" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name           = var.aurora_rds_name
  engine         = "postgres" # This uses RDS, not Aurora
  engine_version = "13.7"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  create_db_cluster_parameter_group = true
  db_cluster_parameter_group_family = "postgres13"
  enabled_cloudwatch_logs_exports   = ["postgresql"]

  # Multi-AZ
  availability_zones        = module.vpc.azs
  allocated_storage         = 256
  db_cluster_instance_class = "db.r6gd.large"
  iops                      = 2500
  storage_type              = "io1"

}

