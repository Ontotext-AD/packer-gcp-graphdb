locals {
  timestamp            = formatdate("YYYYMMDDhhmm", timestamp())
  graphdb_image_family = format("%s-%s", var.image_family_prefix, replace(var.graphdb_version, ".", "-"))
  graphdb_image_name   = format("%s-%s", local.graphdb_image_family, local.timestamp)
}

source "googlecompute" "ubuntu_x86_64" {
  project_id        = var.project_id
  skip_create_image = var.dry_run

  # Source Image
  source_image        = var.source_image
  source_image_family = var.source_image_family

  # GraphDB Image
  image_name              = local.graphdb_image_name
  image_family            = local.graphdb_image_family
  image_description       = "GraphDB ${var.graphdb_version} for Google Cloud Platform"
  image_storage_locations = var.image_storage_locations
  image_project_id        = var.image_project_id
  image_labels            = var.image_labels
  image_licenses          = var.image_licenses

  # Build
  instance_name = "packer-${local.graphdb_image_name}"
  machine_type  = var.build_instance_type
  zone          = var.build_zone
  network       = var.build_network

  tags     = var.build_network_tags
  metadata = var.build_metadata

  use_os_login = false

  # Boot disk
  disk_name = var.disk_name
  disk_size = var.disk_size
  disk_type = var.disk_type

  # Connectivity
  communicator = "ssh"
  ssh_username = var.build_username
}
