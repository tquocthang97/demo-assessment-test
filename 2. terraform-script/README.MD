################
Terraform script deploy VPC, EKS , Aurora RDS


Run below steps:
1. terraform init
2. terraform plan
3. terraform apply --auto-approve


module "aurora" {
  source = "../../"

  name           = local.name
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

  tags = local.tags
}