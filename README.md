# Packer for Creating GraphDB GCP VM Image

[Packer](https://www.packer.io/) configuration for building [GraphDB](https://www.ontotext.com/products/graphdb/) VM images
for [Google Cloud](https://cloud.google.com/).

## About GraphDB

<p align="center">
  <a href="https://www.ontotext.com/products/graphdb/">
    <picture>
      <img src="https://www.ontotext.com/wp-content/uploads/2022/09/Logo-GraphDB.svg" alt="GraphDB logo" title="GraphDB" height="75">
    </picture>
  </a>
</p>

Ontotext GraphDB is a highly efficient, scalable and robust graph database with RDF and SPARQL support. With excellent enterprise features,
integration with external search applications, compatibility with industry standards, and both community and commercial support, GraphDB is
the preferred database choice of both small independent developers and big enterprises.

## What's Included

The VM image includes the following libraries and software:

- GraphDB
- GraphDB Cluster Proxy
- OpenTelemetry
- Google Cloud Ops Agent
- Google Cloud CLI

## Usage

**1. Authentication**

Before being able to run Packer, you have to authenticate your local `gcloud` CLI in Google.
You can follow the official documentation on this here https://cloud.google.com/docs/authentication/gcloud.

**2. Variables**

The Packer configuration in this repository expect you to provide several required variables.
Here's an example `variables.pkrvars.hcl` that you can extend and use:

```hcl
# Required
project_id      = "your-google-cloud-project-id"
build_zone      = "us-east1-b"
graphdb_version = "10.7.0"

# Optional
image_storage_locations = ["us"]
```

You can check the rest of the variables in [variables.pkr.hcl](variables.pkr.hcl).

**3. Running Packer**

After preparing the variables, you can build VM images with:

```shell
packer build -var-file="variables.pkrvars.hcl" .
```

## Observability

The image installs OpenTelemetry Java agent for auto instrumentation of GraphDB as well as Google's own Ops Agent for monitoring VMs.
However, both of them are disabled by default, so to get them working you'd have to:

**Enable Google Cloud Ops Agent**

```shell
systemctl enable google-cloud-ops-agent.service
systemctl start google-cloud-ops-agent.service
```

**Instrument GraphDB**

Edit `/etc/graphdb/graphdb.env` and make sure that the following lines are not commented:

```properties
JAVA_TOOL_OPTIONS="-javaagent:/opt/opentelemetry/opentelemetry-javaagent.jar"
OTEL_RESOURCE_PROVIDERS_GCP_ENABLED="true"
OTEL_SERVICE_NAME="GraphDB"
OTEL_EXPORTER_OTLP_PROTOCOL="grpc"
```

Finally, you'd have to restart GraphDB with:

```shell
systemctl restart graphdb.service
```

## GraphDB Cluster Proxy

By default, the VM will start only the GraphDB systemd service `graphdb.service` on port `7200`. The image has a second systemd service
definition `graphdb_cluster_proxy.service` for a second GraphDB process in cluster proxy mode on port `7201`.

This proxy is used in the clustered setup of GraphDB, see https://graphdb.ontotext.com/documentation/10.7/cluster-basics.html for more
information.

To start the cluster proxy process, use:

```shell
systemctl enable graphdb_cluster_proxy.service
systemctl start graphdb_cluster_proxy.service
```

## Support

For questions or issues related to this Packer configuration,
please [submit an issue](https://github.com/Ontotext-AD/packer-gcp-graphdb/issues).

## License

This code is released under the Apache 2.0 License. See [LICENSE](LICENSE) for more details.
