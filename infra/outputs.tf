# outputs.tf
output "instance_id" {
  value = aws_instance.app_server.id
}

output "instance_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_deploy.arn
}
