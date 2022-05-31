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
    module.cloud-nat-group1.router_name,
    "allow-ssh"
  ]
  metadata = {
    ssh-keys = var.public_ssh
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
    },
    {
      name = "ssh",
      port = 22
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
    module.cloud-nat-group1.router_name,
    "allow-ssh"
  ]
  metadata = {
    ssh-keys = var.public_ssh
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
    },
    {
      name = "tcp",
      port = 22
  }]
  network    = google_compute_network.default.self_link
  subnetwork = google_compute_subnetwork.group1.self_link
}