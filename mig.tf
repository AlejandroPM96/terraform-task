provider "google" {
  project     = var.project
  credentials = file(var.credentials_file)
}

provider "google-beta" {
  project     = var.project
  credentials = file(var.credentials_file)
}

module "mig1_template" {
  source     = "terraform-google-modules/vm/google//modules/instance_template"
  version    = "6.2.0"
  network    = google_compute_network.default.self_link
  subnetwork = google_compute_subnetwork.group1.self_link
  service_account = {
    email  = ""
    scopes = ["cloud-platform"]
  }
  name_prefix          = "${var.network_prefix}-group1"
  startup_script       = file(var.script_path)
  source_image_family  = "ubuntu-1804-lts"
  source_image_project = "ubuntu-os-cloud"
  tags = [
    "${var.network_prefix}-group1",
    module.cloud-nat-group1.router_name
  ]
  metadata = {
    ssh-keys = "JUMPSERVER:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCYnKJUsLsSWhxgR9qcsxoxKDAp5RmkvXJcyL+XdBwFQLjAQ3ExIy5Q9hHxw9t9Rj0lYlMUotS/kN8I7RoX5Ly8z72Ni2B8j3/rXycQmHXLith5CG+Co6Cs3bEdmCiX+6BGbA+wbC9Kg2Ln69kUF6aUhsFDw9SmXMXO80DB1LIW1LhBSOSuknTcE1+CfcbV1id1q5A7Z+hsDeHy+DYAN6tR5BAVgecdpS1QZVfDc2QLNdX89W2UWdjKE6ASTNbsTpzv6ktk7Blt0LAKiRQZxy/A64SzK9YwS6GObtfzO6KCulXZdbBgmpyVKhqyCvPdo7/mdBIVS1e99F5uMUFfHthJ JUMPSERVER"
  }
}

module "mig1" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "6.2.0"
  instance_template = module.mig1_template.self_link
  region            = var.group1_region
  hostname          = "${var.network_prefix}-group1"
  target_size       = var.target_size
  named_ports = [{
    name = "http",
    port = 80
  }]
  network    = google_compute_network.default.self_link
  subnetwork = google_compute_subnetwork.group1.self_link
}

module "mig2_template" {
  source     = "terraform-google-modules/vm/google//modules/instance_template"
  version    = "6.2.0"
  network    = google_compute_network.default.self_link
  subnetwork = google_compute_subnetwork.group1.self_link
  service_account = {
    email  = ""
    scopes = ["cloud-platform"]
  }
  name_prefix          = "${var.network_prefix}-group2"
  startup_script       = file(var.script_path)
  source_image_family  = "ubuntu-1804-lts"
  source_image_project = "ubuntu-os-cloud"
  tags = [
    "${var.network_prefix}-group1",
    module.cloud-nat-group1.router_name
  ]
  metadata = {
    ssh-keys = "JUMPSERVER:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCYnKJUsLsSWhxgR9qcsxoxKDAp5RmkvXJcyL+XdBwFQLjAQ3ExIy5Q9hHxw9t9Rj0lYlMUotS/kN8I7RoX5Ly8z72Ni2B8j3/rXycQmHXLith5CG+Co6Cs3bEdmCiX+6BGbA+wbC9Kg2Ln69kUF6aUhsFDw9SmXMXO80DB1LIW1LhBSOSuknTcE1+CfcbV1id1q5A7Z+hsDeHy+DYAN6tR5BAVgecdpS1QZVfDc2QLNdX89W2UWdjKE6ASTNbsTpzv6ktk7Blt0LAKiRQZxy/A64SzK9YwS6GObtfzO6KCulXZdbBgmpyVKhqyCvPdo7/mdBIVS1e99F5uMUFfHthJ JUMPSERVER"
  }
}

module "mig2" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "6.2.0"
  instance_template = module.mig2_template.self_link
  region            = var.group1_region
  hostname          = "${var.network_prefix}-group2"
  target_size       = var.target_size
  named_ports = [{
    name = "http",
    port = 80
  }]
  network    = google_compute_network.default.self_link
  subnetwork = google_compute_subnetwork.group1.self_link
}