resource "cloudflare_r2_bucket" "this" {
  account_id   = var.account_id
  name         = var.bucket_name
  location     = var.location
  jurisdiction = var.jurisdiction
}

resource "cloudflare_r2_bucket_lifecycle" "this" {
  account_id   = var.account_id
  bucket_name  = cloudflare_r2_bucket.this.name
  jurisdiction = var.jurisdiction

  rules = [{
    id      = "abort-incomplete-multipart-uploads"
    enabled = true

    conditions = {
      prefix = ""
    }

    abort_multipart_uploads_transition = {
      condition = {
        max_age = var.abort_incomplete_multipart_upload_days * 86400
        type    = "Age"
      }
    }
  }]
}

resource "cloudflare_r2_bucket_cors" "this" {
  count = var.enable_cors ? 1 : 0

  account_id   = var.account_id
  bucket_name  = cloudflare_r2_bucket.this.name
  jurisdiction = var.jurisdiction

  rules = [{
    allowed = {
      # POST is needed alongside PUT/DELETE for multipart uploads
      # (CreateMultipartUpload/CompleteMultipartUpload use POST; parts
      # themselves are PUT) -- not just single-shot object writes.
      methods = ["GET", "PUT", "POST", "DELETE"]
      origins = var.cors_allowed_origins
      headers = ["*"]
    }
    max_age_seconds = 3600
  }]
}
