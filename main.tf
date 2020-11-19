# Provider Config
provider "google" {
  version = "3.5.0"
  credentials = file("/root/.config/gcloud/application_default_credentials.json")
  project = "psd-devops-coe"
  region  = "europe-west4"
  zone    = "europe-west4-b"
}

provider "random" {}

# Random string for later
resource "random_pet" "name" {}

# VPC
resource "google_compute_network" "vpc_network" {
  name = "${var.env_name}-vpc"
} 

# VPC firewall rules - ssh,http,icmp
resource "google_compute_firewall" "default" {
  name    = "${var.env_name}-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Image
data "google_compute_image" "rhel_image" {
  family  = "rhel-7"
  project = "rhel-cloud"
}

# Instance
resource "google_compute_instance" "web" {
  name         = random_pet.name.id
  machine_type = var.machine_type
  tags = ["web"]
  metadata_startup_script = file("init-script.sh")

  boot_disk {
    initialize_params {
      image = data.google_compute_image.rhel_image.self_link
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}

output "domain-name" {
  value = google_compute_instance.web.network_interface.0.access_config.0.nat_ip
}
