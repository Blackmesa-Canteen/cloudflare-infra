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
  description = "Optional performance/placement hint (\"apac\", \"eeur\", \"enam\", \"weur\", \"wnam\", \"oc\") -- NOT a data-residency guarantee. Leave null to let Cloudflare choose. See jurisdiction for actual data residency."
  default     = null
}

variable "jurisdiction" {
  type        = string
  description = "Legal jurisdiction objects are guaranteed to stay within: \"default\", \"eu\", \"fedramp\", or \"us\". Cannot be changed after creation without recreating the bucket."
  default     = "default"
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
