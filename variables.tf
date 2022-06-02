variable "project" {
  type    = string
  default = "terraform-project-352021"
}

variable "credentials_file" {
  type    = string
  default = "../terraform-project-352021-a4c9ee05f5a2.json"
}
variable "ssh_key" {
  type    = string
  default = "../rsa_key"
}

variable "target_size" {
  type    = number
  default = 1
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
variable "public_ssh" {
  type    = string
  default = "JUMPSERVER:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCYnKJUsLsSWhxgR9qcsxoxKDAp5RmkvXJcyL+XdBwFQLjAQ3ExIy5Q9hHxw9t9Rj0lYlMUotS/kN8I7RoX5Ly8z72Ni2B8j3/rXycQmHXLith5CG+Co6Cs3bEdmCiX+6BGbA+wbC9Kg2Ln69kUF6aUhsFDw9SmXMXO80DB1LIW1LhBSOSuknTcE1+CfcbV1id1q5A7Z+hsDeHy+DYAN6tR5BAVgecdpS1QZVfDc2QLNdX89W2UWdjKE6ASTNbsTpzv6ktk7Blt0LAKiRQZxy/A64SzK9YwS6GObtfzO6KCulXZdbBgmpyVKhqyCvPdo7/mdBIVS1e99F5uMUFfHthJ JUMPSERVER"
}

variable "script_path" {
  type    = string
  default = "./startup.sh"
}
variable "app_script_path" {
  type    = string
  default = "./appStartup.sh"
}
