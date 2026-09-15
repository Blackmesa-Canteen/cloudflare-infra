module "notes_sync_bucket" {
  source = "../../modules/r2-bucket"

  account_id  = var.cloudflare_account_id
  bucket_name = var.bucket_name

  # EU jurisdiction, matching the tfstate bucket. Cannot be changed later
  # without recreating the bucket (and re-syncing the whole vault).
  jurisdiction = "eu"

  # LiveSync's requests still go through Electron/Capacitor's fetch(),
  # which enforces CORS like a browser would. Without this, connecting
  # fails with "Failed to fetch" unless the plugin's non-standard
  # "Use internal API" workaround is enabled instead. Origins are
  # LiveSync's fixed app identifiers, not configurable per-user:
  # desktop, iOS, and Android respectively.
  enable_cors = true
  cors_allowed_origins = [
    "app://obsidian.md",
    "capacitor://localhost",
    "http://localhost",
  ]
}
