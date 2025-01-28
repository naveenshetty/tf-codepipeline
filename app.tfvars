# Common
project = "e2esa-tutorials"

# General 
aws_region = "us-east-1"

ami               = "ami-0ac4dfaf1c5c0cce9"
availability_zone = "us-east-1a"

project_name             = "ProjectwithEC2"
project_desc             = "Sample project desc"
environment_compute_type = "BUILD_GENERAL1_SMALL"
environment_image        = "aws/codebuild/standard:5.0" # AWS CodeBuild standard image, if it is terraform use that immage
environment_type         = "LINUX_CONTAINER"
environment_variables = [
  {
    name  = "KEY"
    value = "VALUE"
    type  = "PLAINTEXT"
  }
]

report_build_status          = false
source_version               = "main"
buildspec_file_absolute_path = "buildspec_apply.yml"
source_location              = "naveenshetty/myflaskapp.git"

s3_bucket_id                   = "dockerblat"
full_repository_id             = "naveenshetty/myflaskapp"
codestar_connector_credentials = "arn:aws:codeconnections:eu-west-1:325149554414:connection/55efc8b2-a3b6-454b-bd74-9741e6c4e003"

ecr_uri   = "325149554414.dkr.ecr.us-east-1.amazonaws.com/naveen/my-flask-app"
key_pair  = "privatekey"
vpc_id    = "vpc-02c7fbe394d844b44"
ec2_names = ["ec21"]
user_data = "user_data.sh"