# terraform apply -var-file="app.tfvars" -var="createdBy=e2esa"

locals {
  tags = {
    Project     = var.project
    CreatedBy   = var.createdBy
    CreatedOn   = timestamp()
    Environment = terraform.workspace
  }
}


# Define Security Group
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow SSH traffic (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  tags = local.tags
}

resource "aws_iam_role" "ec2_role" {
  name = "EC2-Instance-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "ec2_ecr_policy" {
  name       = "ec2-ecr-policy-attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ecr-instance-profile"
  role = aws_iam_role.ec2_role.name
}

module "ec2" {
  source = "../terraform/providers/aws/modules/e2esa-module-aws-ec2"
  # source             = "git::https://github.com/e2eSolutionArchitect/terraform.git//providers/aws/modules/e2esa-module-aws-ec2?ref=main"
  for_each               = toset(var.ec2_names) # toset(["ec21","ec22"])
  ami                    = var.ami
  availability_zone      = var.availability_zone
  key_name               = var.key_pair # Ensure this is passing the key pair variable
  tags                   = local.tags
  vpc_security_group_ids = [aws_security_group.app_sg.id] # Make sure this line is included
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  # User Data for Docker Setup
  user_data = file("user_data.sh")
}



module "codepipeline" {
  source                         = "../terraform/providers/aws/modules/e2esa-module-aws-codepipeline"
  project_name                   = var.project_name
  s3_bucket_id                   = var.s3_bucket_id
  full_repository_id             = var.full_repository_id
  codestar_connector_credentials = var.codestar_connector_credentials
  tags                           = local.tags
}

# CodeBuild Module
module "codebuild" {
  source                       = "../terraform/providers/aws/modules/e2esa-module-aws-codebuild"
  project_name                 = var.project_name
  project_desc                 = var.project_desc
  environment_compute_type     = var.environment_compute_type
  environment_image            = var.environment_image
  environment_type             = var.environment_type
  source_location              = var.source_location
  environment_variables        = var.environment_variables
  report_build_status          = var.report_build_status
  source_version               = var.source_version
  buildspec_file_absolute_path = var.buildspec_file_absolute_path
  tags                         = local.tags
  #github_repo_url   = "https://github.com/naveenshetty/myflaskapp.git"
  # artifact_bucket   = module.s3.bucket_name
}