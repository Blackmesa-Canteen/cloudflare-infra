terraform {
  required_version = ">= 1.5.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }

  # State lives in a small, dedicated R2 bucket created during the one-time
  # bootstrap (see README.md "Bootstrap"). `endpoints.s3` is deliberately
  # left out here — Terraform's backend block can't reference var.* at all
  # (it's resolved before the variable system exists), so it can't read
  # var.cloudflare_account_id directly. Rather than hardcode a second copy
  # of the account ID here, CI supplies it via -backend-config, generated
  # from the same CLOUDFLARE_ACCOUNT_ID variable that feeds
  # var.cloudflare_account_id elsewhere in this stack — one source of
  # truth. Running `terraform init` locally needs the same flag; see
  # README.md.
  backend "s3" {
    bucket                      = "tfstate"
    key                         = "notes-sync/terraform.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}

provider "cloudflare" {
  # Reads CLOUDFLARE_API_TOKEN from the environment.
}
