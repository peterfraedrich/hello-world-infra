resource "google_storage_bucket" "app-bucket" {
  name = "hello-world-bucket-kjandsflfgkajbgjr"
}

resource "google_storage_bucket_object" "hello-world-source" {
  name   = "hello-world.zip"
  bucket = google_storage_bucket.app-bucket.name
  source = "hello-world.zip"
}
