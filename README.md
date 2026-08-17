# GitHub Repositories for Maven Central Publishing (Terraform)

This Terraform project automates the creation and configuration of GitHub repositories with everything needed to build, test, sign, publish to **Maven Central (Sonatype Portal)**, and create **GitHub Releases** on tag pushes.

It supports:
- **Build Tools**: Gradle, SBT, and Maven.
- **Languages**: Kotlin, Java, and Scala.
- **Publish Flow**: Two-stage CI/CD pipeline following the flow from `~/cumulus.dotfiles` and `commons-web`.
- **Automatic GPG Key Retrieval**: Automatically extracts your ASCII-armored private key from your local GPG keyring at runtime without requiring manual copy-pasting.

---

## Features

1. **Automatic Local GPG Key Extraction**:
   Extracts your private GPG key directly from the local GPG keyring via [`scripts/get_gpg_key.sh`](file:///home/petrolal/Projects/IaC/github-publish-maven/scripts/get_gpg_key.sh). You can optionally specify `gpg_key_id` or let it detect your active key automatically.

2. **Automated Secret Configuration**:
   Configures the following GitHub Actions secrets automatically on each repository:
   - `MAVEN_CENTRAL_USERNAME` / `SONATYPE_USERNAME`
   - `MAVEN_CENTRAL_PASSWORD` / `SONATYPE_PASSWORD`
   - `SIGNING_KEY` / `PGP_SECRET`
   - `SIGNING_PASSWORD` / `PGP_PASSPHRASE`

3. **Tailored CI/CD Workflows (`.github/workflows/deploy.yml`)**:
   Automatically commits the appropriate GitHub Actions workflow file according to the chosen `build_tool`:
   - **`gradle`**: Configured with `gradle/actions/setup-gradle@v3`, `./gradlew check build`, automated GPG key decoding, `./gradlew publishAndReleaseToMavenCentral`, and GitHub Release creation via `softprops/action-gh-release@v2`.
   - **`sbt`**: Follows the `cumulus.dotfiles` release flow (`sbt/setup-sbt@v1`, caching, `sbt compile test`, `sbt ci-release`, and GitHub Release creation).
   - **`maven`**: Configured with `mvn clean verify`, GPG signing import, `mvn clean deploy`, and GitHub Release creation.

4. **Multi-Stage Pipeline**:
   - `build-and-test` runs first on any tag push (`v*`).
   - `publish-and-release` (or `publish-maven-central` + `create-release`) runs only after tests pass.

---

## Getting Started

### 1. Prerequisites
- [Terraform](https://www.terraform.io/) >= 1.5.0 installed.
- GitHub Personal Access Token (PAT) with `repo` and `admin:repo_hook` scopes.
- Sonatype Maven Central Portal token credentials.
- Local GPG secret key already generated/configured in your system.

### 2. Setup Terraform Variables
Copy the example file:
```bash
cp terraform.tfvars.example terraform.tfvars
```
Edit `terraform.tfvars`:
```hcl
github_token           = "ghp_..."
github_owner           = "petrolal"
maven_central_username = "your_sonatype_token_username"
maven_central_password = "your_sonatype_token_password"

# Leave signing_key omitted or null to automatically extract it from your system!
# gpg_key_id          = "C7A30CAF507B01B9F4BED6C3D79966B7698B8A7D" # optional
signing_password       = "your_passphrase"

repositories = {
  "my-kotlin-lib" = {
    description      = "Kotlin library on Maven Central"
    language         = "kotlin"
    build_tool       = "gradle"
    jdk_version      = "21"
    jdk_distribution = "corretto"
  },
  "my-scala-lib" = {
    description      = "Scala library on Maven Central"
    language         = "scala"
    build_tool       = "sbt"
    jdk_version      = "21"
    jdk_distribution = "graalvm-community"
  },
  "my-java-lib" = {
    description      = "Java library on Maven Central"
    language         = "java"
    build_tool       = "maven"
    jdk_version      = "21"
    jdk_distribution = "temurin"
  }
}
```

### 3. Deploy with Terraform
```bash
terraform init
terraform plan
terraform apply
```

---

## Triggering a Release

Once a repository is created, push a tag to trigger the automated build, test, sign, publish, and GitHub release:

```bash
git tag v1.0.0
git push origin v1.0.0
```
