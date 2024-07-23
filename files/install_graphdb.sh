#!/usr/bin/env bash

# This script performs the following tasks:
# * Sets the timezone to UTC.
# * Adjusts system settings for keepalive and file max size.
# * Disables the interactive debconf.
# * Installs necessary tools such as bash-completion, jq, nvme-cli, openjdk-11-jdk, and unzip.
# * Creates a system user "graphdb" for GraphDB service.
# * Creates GraphDB directories and sets up the necessary permissions.
# * Downloads and installs GraphDB, configuring systemd for GraphDB and GraphDB proxy.
# * Downloads and installs Google Cloud Ops Agent.
# * Downloads and installs OpenTelemetry Java agent.
# * Clears the apt cache
# * Clears authorized_keys files for security.

set -o errexit
set -o nounset
set -o pipefail

echo "##############################"
echo "#    Begin Image Creation    #"
echo "##############################"

# --------------------------------------

echo "Setting up system properties..."

timedatectl set-timezone UTC

echo 'net.ipv4.tcp_keepalive_time = 120' | tee -a /etc/sysctl.conf
echo 'fs.file-max = 262144' | tee -a /etc/sysctl.conf

sysctl -p

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# --------------------------------------

echo "Waiting for outbound connectivity..."

until ping -c 1 google.com &>/dev/null; do
  echo -n "."
  sleep 5
done

# --------------------------------------

echo "Installing tools and libraries...."

apt-get update -qq
apt-get install -qq -y bash-completion jq nvme-cli openjdk-11-jdk unzip > /dev/null

# --------------------------------------

echo "Downloading and installing GraphDB..."

useradd --comment "GraphDB Service User" --create-home --system --shell /bin/bash --user-group graphdb

mkdir -p /etc/graphdb \
         /etc/graphdb-cluster-proxy \
         /var/opt/graphdb/node \
         /var/opt/graphdb/cluster-proxy

cd /tmp
curl -fsSL -O https://maven.ontotext.com/repository/owlim-releases/com/ontotext/graphdb/graphdb/"${GRAPHDB_VERSION}"/graphdb-"${GRAPHDB_VERSION}"-dist.zip

unzip -qq graphdb-"${GRAPHDB_VERSION}"-dist.zip
rm graphdb-"${GRAPHDB_VERSION}"-dist.zip
mv graphdb-"${GRAPHDB_VERSION}" /opt/graphdb-"${GRAPHDB_VERSION}"
ln -s /opt/graphdb-"${GRAPHDB_VERSION}" /opt/graphdb

mv /tmp/graphdb.env /etc/graphdb/graphdb.env
mv /tmp/graphdb-cluster-proxy.env /etc/graphdb-cluster-proxy/graphdb-cluster-proxy.env

chown -R graphdb:graphdb /etc/graphdb \
                         /etc/graphdb-cluster-proxy \
                         /opt/graphdb \
                         /opt/graphdb-${GRAPHDB_VERSION} \
                         /var/opt/graphdb

mv /tmp/graphdb.service /lib/systemd/system/graphdb.service
mv /tmp/graphdb-cluster-proxy.service /lib/systemd/system/graphdb-cluster-proxy.service

systemctl daemon-reload
systemctl enable graphdb.service

# --------------------------------------

echo "Downloading and installing Google Cloud Ops Agent..."

# https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent/installation#joint-install
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install > /dev/null 2>&1

mv /tmp/google-cloud-ops-agent-config.yaml /etc/google-cloud-ops-agent/config.yaml
chmod 644 /etc/google-cloud-ops-agent/config.yaml

# Disabled by default
systemctl disable google-cloud-ops-agent.service

# --------------------------------------

echo "Downloading OpenTelemetry Java agent..."

mkdir -p /opt/opentelemetry/
curl -fsSL -o /opt/opentelemetry/opentelemetry-javaagent.jar "https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OPEN_TELEMETRY_VERSION}/opentelemetry-javaagent.jar"
chmod 644 /opt/opentelemetry/opentelemetry-javaagent.jar

# --------------------------------------

echo "Cleaning residual files and authorized keys..."

apt-get clean autoclean
shred -u /root/.ssh/authorized_keys /home/packer/.ssh/authorized_keys || true

# --------------------------------------

echo "#################################"
echo "#    Image Creation Complete    #"
echo "#################################"
