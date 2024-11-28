# The AWS provider is used per the Cloudflare R2 documentation, as this
# provides more capabilities around uploads and other options with S3.
# The documentation for using the AWS Terraform provider with Cloudflare
# R2 can be found here: https://developers.cloudflare.com/r2/examples/terraform-aws/
#
# It is important to note that R2 is NOT 100% compatible with S3!
# See the compatibility matrix here: https://developers.cloudflare.com/r2/api/s3/api/

resource "aws_s3_bucket" "nixos_images" {
    bucket = "nixos-images"
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.example.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "digital_ocean_base_images" {
    bucket  = aws_s3_bucket.nixos_images.id
    source = var.nixos_image_store_path
    etag = var.nixos_image_derivation_path
}
