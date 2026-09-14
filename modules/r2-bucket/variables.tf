variable "account_id" {
  type        = string
  description = "Cloudflare account ID that owns the bucket."
}

variable "bucket_name" {
  type        = string
  description = "Name of the R2 bucket."
}

variable "location" {
  type        = string
  description = "Optional R2 jurisdiction/location hint (e.g. \"apac\", \"eeur\", \"enam\", \"weur\", \"oc\"). Leave null to let Cloudflare choose."
  default     = null
}

variable "abort_incomplete_multipart_upload_days" {
  type        = number
  description = "Days after which incomplete multipart uploads are aborted, so partial/failed sync uploads don't quietly accumulate storage cost."
  default     = 7
}

variable "enable_cors" {
  type        = bool
  description = "Allow cross-origin requests to the bucket. Desktop/mobile LiveSync clients talk to R2 directly and don't need this; only a browser-based client would."
  default     = false
}

variable "cors_allowed_origins" {
  type        = list(string)
  description = "Origins allowed to make cross-origin requests, if enable_cors is true."
  default     = []
}
