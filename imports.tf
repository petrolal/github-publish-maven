# Declarative imports for existing GitHub repositories
# These allow Terraform to manage existing repositories without recreating them.

import {
  to = github_repository.repos["commons-web"]
  id = "commons-web"
}

import {
  to = github_repository.repos["commons-telegram"]
  id = "commons-telegram"
}

import {
  to = github_repository.repos["cumulus.dotfiles"]
  id = "cumulus.dotfiles"
}

import {
  to = github_repository.repos["cumulus.nvim"]
  id = "cumulus.nvim"
}

import {
  to = github_repository.repos["ahun-duty-service"]
  id = "ahun-duty-service"
}

import {
  to = github_repository.repos["ahun-members-service"]
  id = "ahun-members-service"
}
