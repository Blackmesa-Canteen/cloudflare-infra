output "bucket_name" {
  value       = cloudflare_r2_bucket.this.name
  description = "Name of the created R2 bucket."
}

output "bucket_id" {
  value       = cloudflare_r2_bucket.this.id
  description = "ID of the created R2 bucket."
}
