
# Tags
variable "project" {}
variable "createdBy" {}
# General 
variable "aws_region" {}

# EC2 
variable "ami" {}
variable "availability_zone" {}
variable "ec2_names" {
  default = []
  type    = list(string)
}

#codebuild
variable "project_name" {}
variable "environment_compute_type" {}
variable "project_desc" {}
variable "environment_image" {}
variable "environment_type" {}
variable "source_location" {}
variable "environment_variables" {}
variable "report_build_status" {}
variable "source_version" {}
variable "buildspec_file_absolute_path" {}

#codepiplines
variable "policy_name" {}
variable "s3_bucket_id" {}
variable "full_repository_id" {}
variable "codestar_connector_credentials" {}

variable "ecr_uri" {
  description = "ECR URI of the Docker image"
  type        = string
}

variable "key_pair" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the EC2 instance"
  type        = string
}

variable "user_data" {
  description = "User data to configure the EC2 instance"
  type        = string
  default     = null
}