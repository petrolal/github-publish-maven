terraform {
  required_version = ">= 1.5.0"

  cloud {
    # Replace with your HCP Terraform (Terraform Cloud) organization name
    organization = "petrolal-org"

    workspaces {
      name = "github-publish-maven"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}
