variable "namespace" {
  default = "ahead"
}

variable "aws_region" {
  default = "us-east-2"
}

variable "gcp_region" {
  default = "us-central1"
}

provider "aws" {
  region = "${var.aws_region}"
}

provider "google" {
  project = "default-project-160900"
  region  = "${var.gcp_region}"
}

provider "cloudflare" {}
