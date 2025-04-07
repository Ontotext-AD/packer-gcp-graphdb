# Packer Changelog

All notable changes to the Packer configuration for creating GraphDB Google Cloud VM images will be documented in this file.

## 1.3.0

- Updated Ubuntu version to 24.04 LTS
- Updated Java version to temurin-21-jdk

## 1.2.0

- GDB-11622 Disabled GDB JS plugin by default

## 1.1.1

- Disabled the GraphDB JS plugin by default (GDB-11622)

## 1.1.0

- Added `image_licenses` that will be used to associate the built VM image with Google's Marketplace VM license

## 1.0.1

- Renamed `graphdb_cluster_proxy` service to `graphdb-cluster-proxy` for consistency with the rest of our VMs
- Provisioned `/etc/graphdb-cluster-proxy/graphdb-cluster-proxy.env`

## 1.0.0

- Initial release of the Packer configuration
