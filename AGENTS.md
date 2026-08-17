<!-- bmad:context -->
<!-- Verified 2026-08-17 against initial-commit. Managed by bmad-project-context; edits inside this block are replaced on refresh. Keep anything you want preserved outside the markers. -->

## github-publish-maven

Terraform automation project that provisions and configures GitHub repositories with automated CI/CD pipelines (Gradle, Maven, SBT) for Sonatype / Maven Central publishing and GitHub Releases on tag push (`v*`).

## Policy

- Never commit `terraform.tfvars`, `.env*`, or private key material (`*.asc`, `*.gpg`, `secring.*`).
- Use `terraform.tfvars.example` as the canonical template when adding new variables or configuration keys.
- Keep GPG extraction automated via `scripts/get_gpg_key.sh`; avoid hardcoding credentials in HCL.

## Where things are

- Core repository & secrets provisioning: `main.tf`
- Variables and repository schema validation: `variables.tf`
- CI/CD workflow templates: `templates/workflows/` (`gradle.yml.tftpl`, `maven.yml.tftpl`, `sbt.yml.tftpl`)
- Local GPG extraction script: `scripts/get_gpg_key.sh`

## Running and verifying

- Validate configuration and syntax before applying: `terraform fmt -check` and `terraform validate`.
- Test plans safely with dummy/example inputs: `terraform plan -var-file=terraform.tfvars.example`.

## Known pitfalls

- `scripts/get_gpg_key.sh` requires `jq` and `gpg` available locally in `PATH` when executing `terraform plan` or `terraform apply`.
- `github_repository_file` pushes commits directly to `main` with `[skip ci]`; ensure repository default branch matches `main`.

<!-- /bmad:context -->
