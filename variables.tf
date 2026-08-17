variable "github_token" {
  description = "GitHub Personal Access Token with repo administration and secrets permissions"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub user or organization name where repositories will be created (optional, defaults to token owner)"
  type        = string
  default     = null
}

variable "maven_central_username" {
  description = "Sonatype / Maven Central Portal token username"
  type        = string
  sensitive   = true
}

variable "maven_central_password" {
  description = "Sonatype / Maven Central Portal token password"
  type        = string
  sensitive   = true
}

variable "signing_key" {
  description = "Optional GPG ASCII-armored or base64 private key. If omitted, it will be automatically extracted from your local GPG keyring during execution."
  type        = string
  sensitive   = true
  default     = null
}

variable "gpg_key_id" {
  description = "Optional specific GPG Key ID or fingerprint to export from local system (e.g. C7A30CAF507B01B9F4BED6C3D79966B7698B8A7D). If omitted, the first secret key on the system is used."
  type        = string
  default     = null
}

variable "signing_password" {
  description = "Passphrase for the GPG private key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "repositories" {
  description = "Map of repositories to create with Maven Central publishing configured"
  type = map(object({
    description        = optional(string, "Managed by Terraform with Maven Central publishing")
    visibility         = optional(string, "public")
    language           = string # "kotlin", "java", "scala"
    build_tool         = string # "gradle", "maven", "sbt"
    default_branch     = optional(string, "main")
    jdk_version        = optional(string, "21")
    jdk_distribution   = optional(string, "corretto") # e.g. "corretto", "graalvm-community", "temurin"
    topics             = optional(list(string), ["maven-central", "library"])
    has_issues         = optional(bool, true)
    has_wiki           = optional(bool, false)
    license_template   = optional(string, "apache-2.0")
    gitignore_template = optional(string, null)
  }))
  default = {
    "commons-web" = {
      description      = "Foundational Spring Boot auto-configuration library in Kotlin for microservices"
      language         = "kotlin"
      build_tool       = "gradle"
      default_branch   = "master"
      jdk_version      = "21"
      jdk_distribution = "corretto"
      visibility       = "public"
      topics           = ["kotlin", "gradle", "spring-boot", "library", "maven-central"]
    },
    "commons-telegram" = {
      description      = "Spring Boot starter and adapter library in Kotlin for Telegram Bot integration"
      language         = "kotlin"
      build_tool       = "gradle"
      default_branch   = "master"
      jdk_version      = "21"
      jdk_distribution = "corretto"
      visibility       = "public"
      topics           = ["kotlin", "gradle", "spring-boot", "telegram-bot", "library", "maven-central"]
    },
    "cumulus.dotfiles" = {
      description      = "Sway/Wayland desktop configuration and system manager built in Scala 3 with GraalVM Native Image"
      language         = "scala"
      build_tool       = "sbt"
      default_branch   = "master"
      jdk_version      = "21"
      jdk_distribution = "graalvm-community"
      visibility       = "public"
      topics           = ["scala", "sbt", "graalvm", "native-image", "dotfiles", "maven-central"]
    },
    "cumulus.nvim" = {
      description      = "Polyglot JVM intelligence engine for Neovim built in Scala 3 with GraalVM Native Image"
      language         = "scala"
      build_tool       = "sbt"
      default_branch   = "main"
      jdk_version      = "21"
      jdk_distribution = "graalvm-community"
      visibility       = "public"
      topics           = ["scala", "sbt", "neovim", "graalvm", "native-image", "library", "maven-central"]
    },
    "ahun-duty-service" = {
      description      = "Duty management microservice for Casa Ahun in Kotlin / Spring Boot"
      language         = "kotlin"
      build_tool       = "gradle"
      default_branch   = "master"
      jdk_version      = "21"
      jdk_distribution = "corretto"
      visibility       = "public"
      topics           = ["kotlin", "gradle", "spring-boot", "microservice", "maven-central"]
    },
    "ahun-members-service" = {
      description      = "Birthday reminder and members management service for Casa Ahun in Java / Spring Boot"
      language         = "java"
      build_tool       = "gradle"
      default_branch   = "master"
      jdk_version      = "21"
      jdk_distribution = "corretto"
      visibility       = "public"
      topics           = ["java", "gradle", "spring-boot", "microservice", "maven-central"]
    }
  }

  validation {
    condition = alltrue([
      for k, repo in var.repositories : contains(["gradle", "maven", "sbt"], repo.build_tool)
    ])
    error_message = "Supported build_tool values are: 'gradle', 'maven', 'sbt'."
  }

  validation {
    condition = alltrue([
      for k, repo in var.repositories : contains(["kotlin", "java", "scala"], repo.language)
    ])
    error_message = "Supported language values are: 'kotlin', 'java', 'scala'."
  }
}
