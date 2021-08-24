// db module

resource "google_sql_database" "main" {
  name     = "main"
  instance = google_sql_database_instance.main_primary.name
}

resource "google_sql_database_instance" "main_primary" {
  name             = "main-primary"
  database_version = "POSTGRES_12"
  depends_on       = [var.db_depends_on]

  settings {
    tier              = var.instance_type
    availability_type = "ZONAL"
    disk_size         = var.disk_size

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_link
    }
  }
}

resource "google_sql_user" "db_user" {
  name     = var.user
  instance = google_sql_database_instance.main_primary.name
  password = var.password
}
