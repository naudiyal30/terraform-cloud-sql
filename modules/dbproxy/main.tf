
data "google_compute_subnetwork" "regional_subnet" {
  name   = var.vpc_name
  region = var.region
}

resource "google_compute_instance" "db_proxy" {
  name                      = "db-proxy"
  description               = <<-EOT
    A public-facing instance that proxies traffic to the database. This allows
    the db to only have a private IP address, but still be reachable from
    outside the VPC.
  EOT
  machine_type              = var.machine_type
  zone                      = var.zone
  desired_status            = "RUNNING"
  allow_stopping_for_update = true

 
  tags = ["ssh-enabled"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
      size  = 10                     
      type  = "pd-ssd"               
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  metadata_startup_script = templatefile("${path.module}/run_cloud_sql_proxy.tpl", {
    "db_instance_name"    = var.db_instance_name,
    "service_account_key" = module.serviceaccount.private_key,
  })

  network_interface {
    network    = var.vpc_name
    subnetwork = data.google_compute_subnetwork.regional_subnet.self_link

    
    access_config {}
  }

  scheduling {
   
    on_host_maintenance = "MIGRATE"
  }

  service_account {
    email = module.serviceaccount.email

    scopes = ["cloud-platform"]
  }
}

module "serviceaccount" {
  source = "../serviceaccount"

  name = "cloud-sql-proxy"
  role = "roles/cloudsql.editor"
}
