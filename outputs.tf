output "aws_codepipeline_arn" {
  value       = "module.codepipeline.aws_aws_codepipeline_arn"
  description = "AWS codepipeline arn"
}

output "aws_codebuild_project_arn" {
  value       = "module.codebuild.aws_codebuild_project_arn"
  description = "AWS codebuild project arn"
}