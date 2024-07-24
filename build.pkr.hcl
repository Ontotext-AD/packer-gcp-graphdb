build {
  sources = [
    "source.googlecompute.ubuntu_x86_64"
  ]

  provisioner "file" {
    sources = [
      "./files/google-cloud-ops-agent-config.yaml",
      "./files/graphdb.env",
      "./files/graphdb.service",
      "./files/graphdb-cluster-proxy.env",
      "./files/graphdb-cluster-proxy.service",
      "./files/install_graphdb.sh"
    ]
    destination = "/tmp/"
  }

  provisioner "shell" {
    environment_vars = [
      "GRAPHDB_VERSION=${var.graphdb_version}",
      "OPEN_TELEMETRY_VERSION=${var.open_telemetry_version}"
    ]

    inline      = ["sudo -E bash /tmp/install_graphdb.sh"]
    max_retries = var.build_max_retries
  }
}
