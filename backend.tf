terraform {
  backend "s3" {
    bucket = "%%phase%%-%%backend_bucket_name%%"
    key    = "terraform.state"
    region = "%%region%%"
  }
}