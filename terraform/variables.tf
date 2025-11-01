variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-south-1"
}

#variable "vpc_id" {
#  description = "VPC ID where ECS should run"
#  type        = string
#  default     = "vpc-0282307275309e52d" # replace with your default VPC ID
#}

#variable "subnet_ids" {
#  description = "Subnets for ECS tasks"
#  type        = list(string)
#  default     = ["subnet-060f166f319d3926c", "subnet-09b0e0d0168eceedf"] # replace with your actual subnet IDs
#}

variable "docker_image" {
  description = "Full Docker image name (from Docker Hub)"
  type        = string
}

variable "spring_datasource_url" {
  description = "PostgreSQL JDBC URL"
  type        = string
  sensitive   = true
}

variable "spring_datasource_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "spring_datasource_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

