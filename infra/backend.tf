terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "tf-state-gha-node-ci-pipeline-shambhavimaya-code"
    key          = "gha-node-ci-pipeline/terraform.tfstate"
    region       = "us-west-1"
    profile      = "terraform-user" # <-- this line was missing
    use_lockfile = true             # native S3 state locking (Terraform 1.10+, no DynamoDB needed)
    encrypt      = true
  }
}
