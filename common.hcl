# Set common variables for the entire repository.
locals {
  tag_contact = "nshenry03@gmail.com"

  vpc_netnum = {
    "us-west-2"      = 0
    "eu-west-1"      = 1
    "ap-southeast-1" = 2
    "sa-east-1"      = 3
  }
}
