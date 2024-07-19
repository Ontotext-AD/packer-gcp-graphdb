# Common Variables

variable "project_id" {
  description = "Identifier of the project where the VM image building will be executed."
  type        = string
}

variable "dry_run" {
  description = "Skip creating and publishing the VM image. Use for testing or troubleshooting."
  type        = bool
  default     = false
}

# GraphDB Variables

variable "graphdb_version" {
  description = "The version of GraphDB to be installed and packaged as a VM image."
  type        = string
}

# Source Image Variables

variable "source_image" {
  description = "The source image used as the base when the packaging GraphDB VM image. Takes precedence over source_image_family."
  type        = string
  default     = null
}

variable "source_image_family" {
  description = "Name of the source image family used to select the base image when packaging GraphDB. Using this will always select the latest version of the source image in the used family."
  type        = string
  default     = "ubuntu-2204-lts"
}

# GraphDB Image Variables

variable "image_family_prefix" {
  description = "Prefix used when naming the VM image family of the resulting GraphDB VM image."
  type        = string
  default     = "ontotext-graphdb"
}

variable "image_labels" {
  description = "Labels to apply to the built GraphDB VM image."
  type        = map(string)
  default     = {}
}

variable "image_project_id" {
  description = "Identifier of the project for pushing the produced GraphDB VM image. Defaults to project_id."
  type        = string
  default     = null
}

variable "image_storage_locations" {
  description = "Storage location, either regional or multi-regional, where the VM image content will be stored."
  type        = list(string)
  default     = ["us-east1"]
}

# Build Variables

variable "build_instance_type" {
  description = "The machine type used for launching a VM instance that builds the GraphDB VM image"
  type        = string
  default     = "e2-standard-2"
}

variable "build_zone" {
  description = "The zone in which to launch the VM instance used to create the GraphDB VM image."
  type        = string
}

variable "build_network" {
  description = "The Google Compute network ID or URL to use for the VM instance used to build the GraphDB VM image. Defaults to the default network."
  type        = string
  default     = null
}

variable "build_username" {
  description = "The SSH username used for connecting to the build instance by Packer."
  type        = string
  default     = "packer"
}

variable "build_network_tags" {
  description = "List of network tags to apply to the running build VM instance. Use to apply firewall rules."
  type        = list(string)
  default     = ["packer"]
}

variable "build_metadata" {
  description = "Metadata key-value configurations to apply to the running build VM instance."
  type        = map(string)
  default     = {}
}

variable "build_max_retries" {
  description = "Maximum amount of retries when building the GraphDB VM image."
  type        = number
  default     = 2
}

# Boot disk

variable "disk_name" {
  description = "Name of the boot disk for the OS in the GraphDB VM image. Defaults to the name of the launched VM instance for building the GraphDB VM image."
  type        = string
  default     = null
}

variable "disk_size" {
  description = "Disk size in GBs of the boot disk for the GraphDB VM instance."
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "Type of the persistent disk for the GraphDB VM instance boot OS."
  type        = string
  default     = "pd-balanced"
}

# Open Telemetry

variable "open_telemetry_version" {
  description = "Version of the OpenTelemetry Java agent that will be installed in the GraphDB VM image."
  type        = string
  default     = "2.6.0"
}
