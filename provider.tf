terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.88.0"
    }
  }
}

provider "google" {
  project = "idme-328822"
  region  = "us-east1"
}


data "google_project" "IDME" {}
