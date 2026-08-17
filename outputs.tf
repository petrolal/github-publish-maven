output "detected_gpg_key_id" {
  description = "GPG Key ID detected from the system or configured"
  value       = local.resolved_key_id
}

output "created_repositories" {
  description = "Map of created GitHub repositories with their details"
  value = {
    for name, repo in github_repository.repos : name => {
      id         = repo.id
      html_url   = repo.html_url
      ssh_clone  = repo.ssh_clone_url
      http_clone = repo.http_clone_url
      visibility = repo.visibility
    }
  }
}

output "configured_workflows" {
  description = "Workflows configured per repository"
  value = {
    for name, file in github_repository_file.workflow : name => file.file
  }
}
