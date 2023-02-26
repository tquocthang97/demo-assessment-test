variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "max-weather-eks"
}

variable "aurora_rds_name" {
  description = "Aurora RDS NAME "
  type        = string
  default     = "max-weather-rds"
}