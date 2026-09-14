terraform {
  required_version = ">= 1.5.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }

  # State lives in a small, dedicated R2 bucket created during the one-time
  # bootstrap (see README.md "Bootstrap"). The values below are identifiers,
  # not secrets — replace the two placeholders once, after bootstrap, and
  # commit the change. Actual credentials come from AWS_ACCESS_KEY_ID /
  # AWS_SECRET_ACCESS_KEY (an R2 API token pair) in the environment, never
  # committed here.
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

    endpoints = {
      s3 = "https://b5efdc6a06dc7000dc409c2a56d34c2d.r2.cloudflarestorage.com"
    }
  }
}

provider "cloudflare" {
  # Reads CLOUDFLARE_API_TOKEN from the environment.
}
