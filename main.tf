module "vpc" {
  source = "./modules/vpc"
   name = "main-vpc"
}

module "db" {
  source = "./modules/db"

  disk_size     = 10
  instance_type = "db-f1-micro"
  password      = var.db_password
  user          = var.db_username
  vpc_name      = module.vpc.name
  vpc_link      = module.vpc.link
  db_depends_on = module.vpc.private_vpc_connection
}

module "dbproxy" {
  source = "./modules/dbproxy"

  machine_type     = "f1-micro"
  db_instance_name = module.db.connection_name
  region           = var.gcp_region
  zone             = var.gcp_zone
  vpc_name = module.vpc.name
}
