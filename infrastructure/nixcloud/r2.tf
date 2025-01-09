# The AWS provider is used per the Cloudflare R2 documentation, as this
# provides more capabilities around uploads and other options with S3.
# The documentation for using the AWS Terraform provider with Cloudflare
# R2 can be found here: https://developers.cloudflare.com/r2/examples/terraform-aws/
#
# It is important to note that R2 is NOT 100% compatible with S3!
# See the compatibility matrix here: https://developers.cloudflare.com/r2/api/s3/api/

locals {
  do_image_filename = "do.qcow.gz2"
}

resource "aws_s3_bucket" "nixos_images" {
    bucket = "nixos-images-dev"
}

## TODO: Is there a way to apply ACL with R2?
# resource "aws_s3_bucket_acl" "nixos_images_acl" {
#   bucket = aws_s3_bucket.nixos_images.id
#   acl    = "public-read"
# }

# resource "aws_s3_bucket_versioning" "nixos_images_versioning" {
#   bucket = aws_s3_bucket.nixos_images.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

resource "aws_s3_object" "digital_ocean_base_images" {
    bucket  = aws_s3_bucket.nixos_images.id
    key = local.do_image_filename
    source = "${jsondecode(module.digital_ocean_nixos_image.outputs)["out"]}/nixos.qcow2.gz"
    etag = module.digital_ocean_nixos_image.derivation_path
}
