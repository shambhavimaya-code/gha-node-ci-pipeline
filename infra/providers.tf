provider "aws" {
  region  = "us-west-1"
  profile = "terraform-user"

  default_tags {
    tags = {
      Project     = "gha-node-ci-pipeline"
      ManagedBy   = "terraform"
      Environment = "learning"
    }
  }
}
