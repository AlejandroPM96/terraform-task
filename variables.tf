variable "project" {
  type    = string
  default = "terraform-351519"
}

variable "credentials_file" {
  type    = string
  default = "../terraform-351519-db745207ceec.json"
}

variable "target_size" {
  type    = number
  default = 2
}

variable "group1_region" {
  type    = string
  default = "us-central1"
}

variable "group2_region" {
  type    = string
  default = "us-east1"
}

variable "network_prefix" {
  type    = string
  default = "multi-mig-lb-http"
}

variable "script_path" {
  type    = string
  default = "./startup.sh"
}
