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

resource "aws_s3_bucket_acl" "nixos_images_acl" {
  bucket = aws_s3_bucket.nixos_images.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "nixos_images_versioning" {
  bucket = aws_s3_bucket.nixos_images.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "digital_ocean_base_images" {
    bucket  = aws_s3_bucket.nixos_images.id
    # TODO: Dynamic based on filename
    key = "digital_ocean.qcow.gz2"
    source = module.digital_ocean_nixos_image.outputs["out"]
    etag = module.digital_ocean_nixos_image.derivation_path
}
