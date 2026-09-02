terraform {
  backend "s3" {
    bucket       = "oracloud-oracle-data-guard-platform-tf-state"
    key          = "oracle-data-guard/production/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
