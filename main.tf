resource "google_compute_network" "default" {
  name                    = var.network_prefix
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "group1" {
  name                     = "${var.network_prefix}-group1"
  ip_cidr_range            = "10.126.0.0/20"
  network                  = google_compute_network.default.self_link
  region                   = var.group1_region
  private_ip_google_access = true
}

# Router and Cloud NAT are required for installing packages from repos (apache, php etc)
resource "google_compute_router" "group1" {
  name    = "${var.network_prefix}-gw-group1"
  network = google_compute_network.default.self_link
  region  = var.group1_region
}

module "cloud-nat-group1" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "1.4.0"
  router     = google_compute_router.group1.name
  project_id = var.project
  region     = var.group1_region
  name       = "${var.network_prefix}-cloud-nat-group1"
}

resource "google_compute_subnetwork" "group2" {
  name                     = "${var.network_prefix}-group2"
  ip_cidr_range            = "10.127.0.0/20"
  network                  = google_compute_network.default.self_link
  region                   = var.group2_region
  private_ip_google_access = true
}

# Router and Cloud NAT are required for installing packages from repos (apache, php etc)
resource "google_compute_router" "group2" {
  name    = "${var.network_prefix}-gw-group2"
  network = google_compute_network.default.self_link
  region  = var.group2_region
}

module "cloud-nat-group2" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "1.4.0"
  router     = google_compute_router.group2.name
  project_id = var.project
  region     = var.group2_region
  name       = "${var.network_prefix}-cloud-nat-group2"
}

# [START cloudloadbalancing_ext_http_gce]
module "gce-lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 5.1"
  name    = var.network_prefix
  project = var.project
  target_tags = [
    "${var.network_prefix}-group1",
    module.cloud-nat-group1.router_name,
    "${var.network_prefix}-group2",
    module.cloud-nat-group2.router_name
  ]
  ssl               = true
  private_key       = tls_private_key.example.private_key_pem
  certificate       = tls_self_signed_cert.example.cert_pem
  firewall_networks = [google_compute_network.default.name]

  backends = {
    default = {

      description                     = null
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      security_policy                 = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = 80
        host                = null
        logging             = null
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group                        = module.mig1.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
        # {
        #   group                        = module.mig2.instance_group
        #   balancing_mode               = null
        #   capacity_scaler              = null
        #   description                  = null
        #   max_connections              = null
        #   max_connections_per_instance = null
        #   max_connections_per_endpoint = null
        #   max_rate                     = null
        #   max_rate_per_instance        = null
        #   max_rate_per_endpoint        = null
        #   max_utilization              = null
        # },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }
}
# [END cloudloadbalancing_ext_http_gce]

resource "google_compute_instance" "default" {
  depends_on = [
    google_compute_subnetwork.group1
  ]
  name         = "jump-server"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  metadata_startup_script = file("jump_script.sh")
  metadata = {
    GOOGLE_APPLICATION_CREDENTIALS=file("../terraform-project-352021-a4c9ee05f5a2.json"),
    ssh-keys = var.public_ssh
  }
  network_interface {
    network    = var.network_prefix
    subnetwork = "${var.network_prefix}-group1"
    access_config {
      // Ephemeral public IP
    }
  }
  tags = ["jump-server"]
}
resource "google_compute_firewall" "rules" {
  depends_on = [
    google_compute_subnetwork.group1,
    
  ]
  name    = "allow-ssh"
  network = var.network_prefix
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  allow {
    ports    = ["80"]
    protocol = "tcp"
  }
  target_tags   = ["jump-server"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_ssh" {
  depends_on = [
    google_compute_subnetwork.group1
  ]
  name          = "allow-ssh-internal"
  network       = var.network_prefix
  target_tags   = ["allow-ssh"] // this targets our tagged VM
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

output "load-balancer-ip" {
  value = module.gce-lb-http.external_ip
}