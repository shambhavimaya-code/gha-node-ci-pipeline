# 1. Tell AWS to trust tokens issued by GitHub's OIDC provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # GitHub's OIDC thumbprint - AWS validates GitHub's TLS cert chain against this
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

# 2. The IAM role GitHub Actions will "assume" during a workflow run
resource "aws_iam_role" "github_actions_deploy" {
  name = "gha-node-ci-pipeline-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # ONLY this exact repo, ONLY the main branch, may assume this role
            "token.actions.githubusercontent.com:sub" = "repo:shambhavimaya-code/gha-node-ci-pipeline:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

# 3. What the role is allowed to DO once assumed (least privilege - SSM deploy only)
resource "aws_iam_role_policy" "github_actions_deploy_permissions" {
  name = "gha-deploy-permissions"
  role = aws_iam_role.github_actions_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["ec2:DescribeInstances"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:GetObject"]
        Resource = "arn:aws:s3:::tf-state-gha-node-ci-pipeline-shambhavimaya-code/releases/*"
      }
    ]
  })
}
