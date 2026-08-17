# 0. Automatically extract GPG Private Key from local system (or use var.signing_key if provided)
data "external" "local_gpg_key" {
  count   = var.signing_key == null ? 1 : 0
  program = ["bash", "${path.module}/scripts/get_gpg_key.sh"]
  query = {
    key_id     = var.gpg_key_id != null ? var.gpg_key_id : ""
    manual_key = var.signing_key != null ? var.signing_key : ""
    passphrase = var.signing_password
  }
}

locals {
  resolved_signing_key = var.signing_key != null ? var.signing_key : try(data.external.local_gpg_key[0].result["key"], "")
  resolved_key_id      = var.gpg_key_id != null ? var.gpg_key_id : try(data.external.local_gpg_key[0].result["key_id"], "")
}

# 1. Create GitHub Repositories
resource "github_repository" "repos" {
  for_each = var.repositories

  name        = each.key
  description = each.value.description
  visibility  = each.value.visibility
  topics      = each.value.topics

  has_issues   = each.value.has_issues
  has_projects = false
  has_wiki     = each.value.has_wiki

  auto_init        = true
  license_template = each.value.license_template
  gitignore_template = each.value.gitignore_template != null ? each.value.gitignore_template : (
    each.value.language == "scala" ? "Scala" : (
      each.value.language == "kotlin" ? "Kotlin" : "Java"
    )
  )
}

resource "github_repository_vulnerability_alerts" "alerts" {
  for_each   = var.repositories
  repository = github_repository.repos[each.key].name
}

# 2. Configure Required Secrets for Maven Central Publishing
locals {
  repo_secrets = flatten([
    for repo_name, repo_config in var.repositories : [
      {
        repo_name    = repo_name
        secret_name  = "MAVEN_CENTRAL_USERNAME"
        secret_value = var.maven_central_username
      },
      {
        repo_name    = repo_name
        secret_name  = "MAVEN_CENTRAL_PASSWORD"
        secret_value = var.maven_central_password
      },
      {
        repo_name    = repo_name
        secret_name  = "SONATYPE_USERNAME"
        secret_value = var.maven_central_username
      },
      {
        repo_name    = repo_name
        secret_name  = "SONATYPE_PASSWORD"
        secret_value = var.maven_central_password
      },
      {
        repo_name    = repo_name
        secret_name  = "SIGNING_KEY"
        secret_value = local.resolved_signing_key
      },
      {
        repo_name    = repo_name
        secret_name  = "PGP_SECRET"
        secret_value = local.resolved_signing_key
      },
      {
        repo_name    = repo_name
        secret_name  = "SIGNING_PASSWORD"
        secret_value = var.signing_password
      },
      {
        repo_name    = repo_name
        secret_name  = "PGP_PASSPHRASE"
        secret_value = var.signing_password
      }
    ]
  ])
}

resource "github_actions_secret" "secrets" {
  for_each = {
    for entry in local.repo_secrets : "${entry.repo_name}/${entry.secret_name}" => entry
  }

  repository  = github_repository.repos[each.value.repo_name].name
  secret_name = each.value.secret_name
  value       = each.value.secret_value

  depends_on = [github_repository.repos]
}

# 3. Add GitHub Actions CI/CD Deployment Workflow File to each repository (Tag-driven release)
resource "github_repository_file" "workflow" {
  for_each = var.repositories

  repository = github_repository.repos[each.key].name
  branch     = each.value.default_branch
  file       = ".github/workflows/deploy.yml"
  content = templatefile("${path.module}/templates/workflows/${each.value.build_tool}.yml.tftpl", {
    language         = each.value.language
    build_tool       = each.value.build_tool
    jdk_version      = each.value.jdk_version
    jdk_distribution = each.value.jdk_distribution
  })
  commit_message      = "ci: add GitHub Actions workflow for Maven Central publish and release [skip ci]"
  commit_author       = "Terraform"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true

  depends_on = [github_repository.repos]
}

# 4. Add GitHub Actions Standard CI Workflow File to each repository (PR and branch verification)
resource "github_repository_file" "ci_workflow" {
  for_each = var.repositories

  repository = github_repository.repos[each.key].name
  branch     = each.value.default_branch
  file       = ".github/workflows/ci.yml"
  content = templatefile("${path.module}/templates/workflows/ci_${each.value.build_tool}.yml.tftpl", {
    language         = each.value.language
    build_tool       = each.value.build_tool
    jdk_version      = each.value.jdk_version
    jdk_distribution = each.value.jdk_distribution
  })
  commit_message      = "ci: add standard CI verification workflow [skip ci]"
  commit_author       = "Terraform"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true

  depends_on = [github_repository.repos]
}

# 5. Tag Protection Ruleset to prevent deletion or overwriting of release tags (v*)
resource "github_repository_ruleset" "protect_tags" {
  for_each = var.repositories

  name        = "protect-release-tags"
  repository  = github_repository.repos[each.key].name
  target      = "tag"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/tags/v*"]
      exclude = []
    }
  }

  rules {
    deletion = true
    update   = true
  }

  depends_on = [github_repository.repos]
}
