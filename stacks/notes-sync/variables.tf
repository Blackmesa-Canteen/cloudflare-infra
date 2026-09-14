variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID (set via TF_VAR_cloudflare_account_id in CI)."
}

variable "bucket_name" {
  type        = string
  description = "Name of the R2 bucket used for Obsidian Self-hosted LiveSync."
  default     = "notes-sync"
}
