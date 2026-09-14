output "bucket_name" {
  value       = module.notes_sync_bucket.bucket_name
  description = "Name of the notes-sync R2 bucket — plug this into the Obsidian LiveSync plugin settings."
}
