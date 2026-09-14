module "notes_sync_bucket" {
  source = "../../modules/r2-bucket"

  account_id  = var.cloudflare_account_id
  bucket_name = var.bucket_name

  # LiveSync's desktop/mobile clients talk to R2 directly, no browser
  # involved, so CORS stays off. Flip this on (and set
  # cors_allowed_origins) only if a browser-based client is ever added.
  enable_cors = false
}
