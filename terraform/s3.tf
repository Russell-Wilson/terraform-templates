
variable "aws_region" {
    type = string
    nullable = false
}

variable "basename" {
  type = string
  nullable = false
}

provider "aws" {
  region = "${var.aws_region}"
}
    
resource "aws_s3_bucket" "s3-uploads" {
   bucket = "${var.basename}-uploads"
}

resource "aws_s3_bucket_acl" "s3-cms-staging-acl" {
  bucket = aws_s3_bucket.s3-uploads.id
  acl    = "private"
}