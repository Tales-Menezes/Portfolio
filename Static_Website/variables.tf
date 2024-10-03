variable "bucket_name" {
  type        = string
  default     = "tales-website-bucket-files"
  description = "Name of the bucket where the files from the static website will be stored."
}
variable "region" {
  type        = string
  default     = "eu-west-2"
  description = "London region selected for this work."
}
