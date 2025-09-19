# Guided Walkthrough

## Introduction

Welcome to the Kong Workshop on Enhancing API Resilience of the Kong Gateway.

### Workshop Objectives

- Learn how to set up a Kong Gateway Data Plane on your local machine
- Deploy Kong Enterprise Edition, the Control Plane
- Deploy and interact with an upstream microservice
- Simulate failures and delays using Kong plugins
- Enhance the gateway to effectively handle failures and improve performance

By the end of this workshop, you will have hands-on experience in configuring Kong Gateway for improved API resiliency.

---

## Table of Contents

1. [Prerequisites](#prerequisites)

2. [Environment Setup](#environment-setup)

   - [Container Services Deployed via Docker](#container-services-deployed-via-docker)
   - [Gateway(s)](#gateways)
       - [Kong Gateway Configuration Explanation](#kong-gateway-configuration-explanation)
   - [Microservices](#microservices)
   - [Observability Tools](#observability-tools)

3. [Start the Environment](#start-the-environment)

4. [Verify Kong Enterprise Deployment](#verify-kong-enterprise-deployment)

5. [Observability and Monitoring](#observability-and-monitoring)

   - [Setting Up Prometheus, Grafana, Jaeger, Loki, and Otel-collector](#setting-up-prometheus-grafana-jaeger-loki-and-otel-collector)
   - [Setup Kong Metrics Monitoring Capability](#setup-kong-metrics-monitoring-capability)
   - [Setup Kong Logging Capability](#setup-kong-logging-monitoring-capability)
   - [Setup Kong Tracing Capability](#setup-kong-tracing-monitoring-capability)

6. [Configuring the Gateway](#configuring-the-gateway)

   - [Importing Microservice Routes](#importing-microservice-routes)
   - [Test the Base Configuration](#test-the-base-configuration)
     - [Visualise the Generated Traffic](#visualise-the-generated-traffic)

7. [Setup Failure Simulation](#setup-failure-simulation)

   - [Simulate Failure Configuration](#simulate-failure-configuration)

8. [Enhancing API Resilience](#enhancing-api-resilience)

   - [Applying the Upstream Redirect Pattern](#applying-the-upstream-redirect-pattern)
     - [Objectives](#objectives)
     - [Plugin(s) Used](#plugins-used)
     - [Guidance Steps](#guidance-steps)
   - [Configuring Retries and Timeouts](#configuring-retries-and-timeouts)
     - [Objectives](#objectives-1)
     - [Plugin(s) Used](#plugins-used-1)
     - [Guidance Steps](#guidance-steps-1)
   - [Implement Rate Limiting](#implement-rate-limiting)
     - [Objectives](#objectives-2)
     - [Plugin(s) Used](#plugins-used-2)
     - [Guidance Steps](#guidance-steps-2)
   - [Enable Caching to Reduce Load](#enable-caching-to-reduce-load)
     - [Objectives](#objectives-3)
     - [Plugin(s) Used](#plugins-used-3)
     - [Guidance Steps](#guidance-steps-3)
   - [Additional Plugins for API Resilience](#additional-plugins-for-api-resilience)
     - [1. Request Size Limiting Plugin](#1-request-size-limiting-plugin)
     - [2. OpenAPI (OAS) Validation Plugin](#2-openapi-oas-validation-plugin)
     - [3. JSON Threat Protection Plugin](#4-json-threat-protection-plugin)
     - [4. Service Protection Plugin](#5-service-protection-plugin)
     - [5. Injection Protection Plugin](#6-injection-protection-plugin)
     - [6. Bot Detection Plugin](#7-bot-detection-plugin)
     - [7. Request Validator Plugin](#8-request-validator-plugin)

9. [Best Practices](#best-practices)

   - [1. Design for Failure](#1-design-for-failure)
   - [2. Optimise Timeouts and Retries](#2-optimise-timeouts-and-retries)
   - [3. Control Traffic with Rate-Limiting](#3-control-traffic-with-rate-limiting)
   - [4. Reduce Load with Caching](#4-reduce-load-with-caching)
   - [5. Enhance Observability](#5-enhance-observability)
   - [6. Secure Deployments](#6-secure-deployments)

10. [Case Studies](#case-studies)

    - [Case Study 1: Overview](#case-study-1-overview)
    - [Case Study 1: Key Mitigation Measures and Insights](#case-study-1-key-mitigation-measures-and-insights)
      - [1. IP-Based Rate Limiting](#1-ip-based-rate-limiting)
      - [2. Traffic Analysis and Dynamic Blocking](#2-traffic-analysis-and-dynamic-blocking)
      - [3. Custom Blocking Using Patterns](#3-custom-blocking-using-patterns)
      - [4. Geographical Restrictions](#4-geographical-restrictions)
      - [5. Automated Verification with reCAPTCHA](#5-automated-verification-with-recaptcha)
    - [Case Study 1: Lessons Learned](#case-study-1-lessons-learned)
    - [Case Study 1: API Resiliency with Kong Gateway](#case-study-1-api-resiliency-with-kong-gateway)
    - [Case Study 1: Conclusion](#case-study-1-conclusion)

11. [Conclusion](#conclusion)

12. [Troubleshooting Common Issues](#troubleshooting-common-issues)

13. [Cleaning Up Local Environment](#environment-clean-up-workflow)
    - [1. Stop Services & Remove Related Docker Resources](#1-stop-services--remove-related-docker-resources)
    - [2. Remove Unused Containers and Networks](#2-remove-unused-containers-and-networks)
    - [3. (Optional) Remove Unused Volumes](#3-optional-remove-unused-volumes)
    - [4. Clean Up Local Files](#4-clean-up-local-files)
    - [5. Verify the Clean-Up](#5-verify-the-clean-up)

---

## Prerequisites

Ensure your local machine has the following hardware and software requirements:

- **Hardware Requirements**:
  - Minimum 8 GB RAM
  - Minimum 4 CPU cores
  - Minimum 20 GB free disk space

    <br/>

- **Docker & Docker Compose**

  - [**Docker Installation Guide**](https://docs.docker.com/get-docker/)
  - Virtualisation environment; recommended allocated resources:
    - memory set to at least **4GB RAM**
    - CPU set to at least **2 cores**
    - disk space set to at least **20GB**
  - [**Docker Compose Installation Guide**](https://docs.docker.com/compose/install/)

    <br/>

- **Insomnia (Kong's Client App for designing, testing, and debugging API requests)**

  - [**Download Insomnia**](https://insomnia.rest/download)
  - Desktop application used for testing and interacting with APIs

    <br/>

- **Git-Bash (Windows Users)**

  - [**Download Git-Bash**](https://git-scm.com/downloads)
  - Windows application used for running Shell scripts

    <br/>

- **Kong Enterprise License**
    - Ensure that you have a valid license key, and export it for use using the terminal:
      ```shell
      export KONG_LICENSE_DATA="{ ... your-kong-license-data ... }"
      ```

## Environment Setup

To install everything needed for this workshop, we will use the [**deploy-gateway.sh**](./deploy-gateway.sh) script.
The contents of this script as well as the configuration used are outlined in the subsections below.

### Container Services Deployed via Docker

> 💡 **Note**
>
> As previously mentioned, for the purpose of this workshop, the [**docker-compose.yaml**](./docker-compose.yaml) has been
> set up to configure the base environment setup on your local machine with an instance of `decK` installed inside a
> running container.

### Gateway(s)

As part of the installation process of Kong Gateway's Enterprise Edition, the following Kong-built components run 
locally on your machine inside of your Docker environment. 

Within this list of components an additional service called KongAir Routes is included, and will be used as part of this workshop:

| **Name**                                                                                                                                        | **Overview**                                                                                 |
|-------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| [**Kong Control Plane**](https://docs.konghq.com/gateway/latest/production/deployment-topologies/hybrid-mode/setup/#set-up-the-control-plane)   | Manages and propagates configuration across data planes; handles all Kong entities centrally |
| [**Kong Data Plane**](https://docs.konghq.com/gateway/latest/production/deployment-topologies/hybrid-mode/setup/#install-and-start-data-planes) | Executes traffic processing based on configurations received from the control plane          |
| [**Kong Air Routes Service**](https://github.com/Kong/KongAir)                                                                                  | A routes microservice emulating a customer-facing airline system                             |

#### Kong Gateway Configuration Explanation

The Database, Control Plane, and Data Plane configuration are defined in the [**docker-compose.yaml**](./docker-compose.yaml) file.

The environment variables below are used to configure both the Kong Control Plane and Data Planes.

| ENV Variable                        | Control Plane Configuration                                                             | Data Plane Configuration                                                                   |
|-------------------------------------|-----------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| **KONG_LICENSE_DATA**               | Contains the Kong license data                                                          | Contains the Kong license data                                                             |
| **KONG_DATABASE**                   | `postgres` – Uses a PostgreSQL database                                                 | `off` – Data plane is decoupled from a database                                            |
| **KONG_PG_HOST**                    | `db` – Host of the PostgreSQL database                                                  | —                                                                                          |
| **KONG_PG_DATABASE**                | `kong` – Name of the PostgreSQL database                                                | —                                                                                          |
| **KONG_PG_USER**                    | `kong` – PostgreSQL user                                                                | —                                                                                          |
| **KONG_PG_PASSWORD**                | `kong` – PostgreSQL password                                                            | —                                                                                          |
| **KONG_PASSWORD**                   | `password` – Administrative password for Kong                                           | —                                                                                          |
| **KONG_PREFIX**                     | `/tmp/kong` – Working directory for Kong                                                | `/tmp/kong` – Working directory for Kong                                                   |
| **KONG_VITALS**                     | `off` – Kong Vitals monitoring is disabled                                              | `off` – Kong Vitals monitoring is disabled                                                 |
| **KONG_LOG_LEVEL**                  | `notice` – Logging level is set to notice                                               | `notice` – Logging level is set to notice                                                  |
| **KONG_PLUGINS**                    | `bundled,chaos-experiments` – Enables bundled plugins and chaos experiments             | `bundled,chaos-experiments` – Enables bundled plugins and chaos experiments                |
| **KONG_PROXY_LISTEN**               | `off` – Proxy listener is disabled                                                      | `0.0.0.0:8000` – Listens for client traffic                                                |
| **KONG_ADMIN_LISTEN**               | `0.0.0.0:8001` – Exposes the Admin API                                                  | `off` – Admin API is disabled                                                              |
| **KONG_ADMIN_GUI_LISTEN**           | `0.0.0.0:8002` – Exposes the Admin GUI                                                  | `off` – Admin GUI is disabled                                                              |
| **KONG_ROLE**                       | `control_plane` – Designates this instance as the Control Plane                         | `data_plane` – Designates this instance as the Data Plane                                  |
| **KONG_CLUSTER_MTLS**               | `shared` – Uses a shared certificate for mutual TLS within the cluster                  | —                                                                                          |
| **KONG_CLUSTER_CERT**               | `/etc/secrets/kong-cluster/tls.crt` – Path to the TLS certificate used for cluster mTLS | `/etc/secrets/kong-cluster/tls.crt` – Path to the TLS certificate used for cluster mTLS    |
| **KONG_CLUSTER_CERT_KEY**           | `/etc/secrets/kong-cluster/tls.key` – Path to the TLS key used for cluster mTLS         | `/etc/secrets/kong-cluster/tls.key` – Path to the TLS key used for cluster mTLS            |
| **KONG_CLUSTER_CONTROL_PLANE**      | —                                                                                       | `kong-control-plane:8005` – Address of the Control Plane from which to fetch configuration |
| **KONG_CLUSTER_TELEMETRY_ENDPOINT** | —                                                                                       | `kong-control-plane:8006` – Endpoint for sending telemetry data to the Control Plane       |
| **KONG_TRACING_INSTRUMENTATIONS**   | —                                                                                       | `all` – Enables tracing for all supported instrumentations                                 |
| **KONG_TRACING_SAMPLING_RATE**      | —                                                                                       | `1.0` – 100% of requests are sampled for tracing                                           |
| **KONG_STATUS_LISTEN**              | —                                                                                       | `0.0.0.0:8100` – Exposes the Status API for health and operational metrics                 |

### Microservices

Our workshop uses a microservice from [`KongAir`](https://github.com/Kong/KongAir) which retrieves route information 
when the `/routes` and `/route/{ID}` endpoints are called.

> 💡 **Note** 
>
> The `<REGISTRY>` value in the YAML should be replaced with the internal registry Fully-Qualified Domain Name (FQDN), and `<DATE>` should correspond with the date of this workshop.
> Please let one of the team know if this image is inaccessible.

```yaml
  kongair-routes:
    container_name: kongair-routes
    image: <REGISTRY>/kongair-routes:ws-<DATE>
    hostname: routes.kongair
    restart: on-failure
    networks:
      - kong-net
    ports:
      - "5053:8080"
```

### Observability Tools

To monitor and visualise the performance of the Kong Gateway and microservice(s), we include the below observability
and traceability tools:

| **Name**                                                                                            | **Overview**                                                                                |
|-----------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------|
| [**DB (Postgres)**](https://docs.konghq.com/gateway/latest/install/post-install/set-up-data-store/) | Centralised datastore used by the control plane to persist Kong configurations and entities |
| [**Prometheus**](https://prometheus.io/)                                                            | A robust, time-series database and monitoring system used to scrape metrics from services   |
| [**Grafana**](https://grafana.com/)                                                                 | Visualisation and analytics platform for metrics, logs, and traces                          |
| [**FluentBit**](https://fluentbit.io/how-it-works/)                                                 | A lightweight, fast, and scalable log processor and forwarder                               |
| [**OpenTelemetry Collector**](https://opentelemetry.io/docs/collector/)                             | A vendor-agnostic collector for traces, metrics, and logs                                   |
| [**Loki**](https://grafana.com/oss/loki/)                                                           | A horizontally scalable, highly available log aggregation system inspired by Prometheus     |
| [**Jaeger**](https://www.jaegertracing.io/)                                                         | A distributed tracing system developed by Uber                                              |

These services have been outlined in the [**docker-compose.yaml**](./docker-compose.yaml) file.

---

## Start the Environment

> 💡 **Note** 
>
> Per note above:
> "For the purpose of this workshop, the [**docker-compose.yaml**](./docker-compose.yaml) has been set up to configure the
> base environment setup on your local machine. If you would like to apply the configuration to the Gateway manually,
> please comment out the `services.deck` YAML configuration. The commands that need to be run can be found within the
> [**deck-init-apply.sh**](./deck-init-apply.sh) script." The script will generate the `kong.yaml` file which can be
> applied using `deck` commands.

Using the command-line, from the root of the repository run the [**deploy-gateway.sh**](./deploy-gateway.sh) script to init the environment
and start all services:

```shell
./deploy-gateway.sh
```

This deployment script runs the following:

- Generates TLS certificate & key using the [**certificate-key-generation.sh**](./certificate-key-generation.sh) script
- Starts the services using `docker-compose up -d` command
- Generates the [**kong.yaml**](./deck/kong.yaml) file using the [**deck-init-apply.sh**](./deck-init-apply.sh) script

The [**deck-init-apply.sh**](./deck-init-apply.sh) script generates the `kong.yaml` file which contains the configuration 
for the Kong Gateway.
The contents of this script are primarily `deck` commands. 

These can be run manually **after the workshop** has finished so you may better understand the commands and their output in more detail.

> 💡 **Note** 
>
> The first time that this is run, Docker will need to pull all the images which may take a few minutes.

Verify that all services are running using the following command:

```shell
docker-compose ps
```

All services listed should be shown with the status `Up`; the `deck` container status should show an `Exited` status.

Checking inside the `deck` container logs, using the below command, should show a line saying that the `Setup is Complete`:

```shell
docker-compose logs deck 
```

This is a clear indicator that the [**kong.yaml**](./deck/kong.yaml) file has been generated and was applied to the Kong
Gateway successfully. You should also see this file in the root of the repository under the [**deck**](./deck) directory.

Once the services are up and running, please move on to the next section. 

> 💡 **Note** 
>
> In the case that these services are not showing this status, please check the logs and/or reach out to one of the 
> workshop facilitators for further assistance.

---

## Verify Kong Enterprise Deployment

To confirm that your Control Plane and Data Plane are running correctly, run the below command:

```shell
docker-compose ps
```

This will display the status of the containers listed in the [**docker-compose.yaml**](./docker-compose.yaml) file. Each 
service should be in a `running (ealthy)` state. 

If any service is in an `exited` or `unhealthy` state, investigate further. Be sure to refer to the [**Troubleshooting documentation**](./TROUBLESHOOTING.md#Enterprise-Control-Plane-and-Data-Plane-Connectivity-Issues)

Open up a browser window and navigate to Kong Manager using following address:

```
http://localhost:8002
```


Alternatively, use the Admin API to check status of the control plane:
```shell
curl localhost:8001/status
```

## Observability and Monitoring

Monitoring is essential to understand how a systems' services are performing and to detect issues

Before the routes and services are adjusted in the gateway with additional plugins, it is important to ensure that the
Observability functionality is working correctly.

### Setting Up Prometheus, Grafana, Jaeger, Loki and Otel-collector

Prometheus, Grafana, Jaeger, Loki and Otel-collector components are already included in the overall docker-compose setup,
per the instructions outlined in the [`observability tools`](#observability-tools) section. Here we will just need to
configure the plugins to enable the observability functionality.

1. Add the below configuration to the [**platform/plugins.yaml**](./platform/plugins.yaml) file which will enable the `prometheus` plugin:

    ```yaml
    - name: prometheus
      enabled: true
      config:
        bandwidth_metrics: true
        latency_metrics: true
        per_consumer: true
        status_code_metrics: true
        upstream_health_metrics: true
      protocols:
      - grpc
      - grpcs
      - http
      - https
    ```

    > 💡 **Note** 
    >
    > Make sure to remove the empty array (`[]`) from the top `plugins:` line, and place the configuration directly under it.

2. Add the below configuration to the [**platform/plugins.yaml**](./platform/plugins.yaml) file which will enable the `http-log` plugin:

    ```yaml
    - name: http-log
      enabled: true
      config:
        custom_fields_by_lua:
          spanid: |
            local h = kong.request.get_header('traceparent') or ''
            if h then
              return h:match("%-[a-f0-9]+%-([a-f0-9]+)%-")
            end
          traceid: "local h = kong.request.get_header('traceparent') or ''\nif h then
            \n  return h:match(\"%-([a-f0-9]+)%-[a-f0-9]+%-\")\nend\n"
        http_endpoint: http://fluentbit:8080
    ```

3. Add the below configuration to the [**platform/plugins.yaml**](./platform/plugins.yaml) file which will enable the `opentelemetry` plugin:

    ```yaml
    - name: opentelemetry
      config:
        traces_endpoint: http://otel-collector:4318/v1/traces
        resource_attributes:
          service.name: kong-otel-plugin
    ```

    Now that these have been added, run the [**deploy-gateway.sh**](./deploy-gateway.sh) script to apply them.

4. Access Grafana

    - Switch over to a browser and open a new tab

    - Input `http://localhost:3000` in the URL bar

    - Hit enter & you will be presented with an authentication screen

    - To log in, use the default credentials:
        - Username: `admin`
        - Password: `admin`

5. Configure Prometheus Data Source

    - In Grafana, navigate to Dashboards

    - Once there you will see the Kong Dashboard present
      
    > 💡 **Note** 
    >
    > This Dashboard was already imported from the [**JSON**](./grafana/dashboards/7424_rev11.json) configuration

### Setup Kong Metrics Monitoring Capability

To enable monitoring of Kong Gateway metrics, we need to activate the `prometheus` plugin in Kong which records and
exposes metrics at the node level. Once enabled, the Prometheus server will discover all Kong nodes via a service 
discovery mechanism, and consumes data from each node's individually configured `/metrics` endpoint.

To enable the `prometheus` plugin in Kong:

1. Using DecK, ensure that the `prometheus` plugin is included in the [**platform/plugins.yaml**](./platform/plugins.yaml) configuration file under plugins

2. Apply using DecK

   - We will be applying the configuration using `decK` with the script below:

     ```shell
     ./deploy-gateway.sh
     ```
 
     Please see the [**Troubleshooting documentation**](./TROUBLESHOOTING.md#Monitoring-Troubleshooting) for more information
     on common issues and how to resolve them.

3. Verify that the Plugin is Enabled:

   - In Kong Manager, navigate to the relevant Workspace and check Services or Plugins to confirm that the plugin is active

     <br/>

     Alternatively, use the Admin API to list plugins for a given Service:
     ```shell
     curl http://localhost:8001/plugins
     ```

---

### Setup Kong Logging Monitoring Capability

To enable logging of Kong Gateway metrics, we need to activate the `http-log` plugin in Kong. This plugin enables 
you send request logs and response logs to a specified HTTP server, and supports stream data (TCP, TLS, UDP) as well.

Enable the `http-log` plugin in Kong:

1. Using DecK, ensure that the `http-log` plugin is included in the [**platform/plugins.yaml**](./platform/plugins.yaml) configuration file


2. Apply using DecK

   - We will be applying the configuration using `decK` with the script below:

     ```shell
     ./deploy-gateway.sh
     ```
 
     Please see the [**Troubleshooting documentation**](./TROUBLESHOOTING.md#Monitoring-Troubleshooting) for more information
     on common issues and how to resolve them.

3. Verify the Plugin is Enabled:

   - In Kong Manager, navigate to the relevant Workspace and check Services or Plugins to confirm that the plugin is active

     <br/>

     Alternatively, use the Admin API to list plugins for a given Service:
     ```shell
     curl http://localhost:8001/plugins
     ```

---

### Setup Kong Tracing Monitoring Capability

To enable logging of Kong Gateway metrics, the `opentelemetry` plugin needs to be activated. This plugin propagates 
distributed tracing spans and reports low-level spans to a specified OTLP-compatible server.

Enable the `opentelemetry` plugin in Kong:

1. Using DecK, ensure that the `opentelemetry` plugin is included in the [**platform/plugins.yaml**](./platform/plugins.yaml) configuration file


2. Apply using decK

   - We will be applying the configuration using `decK` with the script below:

     ```shell
     ./deploy-gateway.sh
     ```
 
     Please see the [**Troubleshooting documentation**](./TROUBLESHOOTING.md#Monitoring-Troubleshooting) for more information
     on common issues and how to resolve them.

3. Verify the Plugin is Enabled:

   - In Kong Manager, navigate to the relevant Workspace and check Services or Plugins to confirm that the plugin is active

     <br/>

     Alternatively, use the Admin API to list plugins for a given Service:
     ```shell
     curl http://localhost:8001/plugins
     ```

---

## Configuring the Gateway

In this section, the Data Plane will be configured via Enterprise using Kong's `decK` functionality

### Importing Microservice Routes

Within this repository, there is an OpenAPI Specification for the `Routes Service` in the [**open-api.yaml**](./kong-air/routes/open-api.yaml) file. 
We will be using this document to generate the Kong Gateway configuration.

Convert the OpenAPI Specification to Kong Configuration:

- The `decK` CLI is used to convert the OpenAPI Specification to Kong configuration
- Below is the command specified inside the **deck-init-apply.sh** file
- This converts the specification while spinning up the instance using deck.

2. Merge Configurations:

    - Combine the generated [**kong-routes.yaml**](./kong-air/routes/kong-routes.yaml) with the existing configuration.

      > 💡**Note**
      > 
      > This is handled automatically by the command defined in the [**deck-init-apply.sh**](./deck-init-apply.sh)
        which runs during container startup via the [**deploy-gateway.sh**](./deploy-gateway.sh) script.

   <br/>

3. Verify Services and Routes in Kong Manager:

    - In Kong Manager, go to `Services` and confirm that `routes-service` and its routes are correctly listed.

### Load and Test the Base Configuration

To ensure that Kong Gateway is correctly routing requests to the Routes-Service, we will send test HTTP requests to it.

**Steps:**

1. Test the `Health check` endpoint:
    
    <br/>

   **Using Insomnia**

    1. Open Insomnia and import a collection present at [**routes-oas.yaml**](./routes-oas.yaml)

    2. In Insomnia, navigate to where the collection has been imported, then navigate to the `/health` endpoint (name in collection: `health/Health check endpoint for Kubernetes`). 
    Choose enviroment "OpenAPI env localhost:8000" to apply pre-configured values in URL templates.

    3. Send the request with expected output:

       ```json
       {
          "status": "OK"
       }
       ```

    <br/>

   **Using cURL**

   1. Run the command below in the terminal:

       ```shell
       curl http://localhost:8000/health
       ```

   2. Send the request with expected output:

       ```json
       {
          "status": "OK"
       }
       ```

    <br/>

2. Test the `Get all KongAir routes` endpoint:

    <br/>

   **Using Insomnia**

    1. In Insomnia, navigate to where the collection has been imported, then navigate to the `/routes` endpoint.

    2. Send the request to receive the following output:
    
        ```json
        [
          {
            "Id": "LHR-JFK",
            "Origin": "LHR",
            "Destination": "JFK",
            "AvgDuration": 470
          },
          {
            "Id": "LHR-SFO",
            "Origin": "LHR",
            "Destination": "SFO",
            "AvgDuration": 660
          },
          {
            "...omitted...": "..."
          },
          {
            "Id": "LHR-LAX",
            "Origin": "LHR",
            "Destination": "LAX",
            "AvgDuration": 675
          }
        ]
        ```

   <br/>

   **Using cURL**

   1. Run the command below in the terminal:

       ```shell
       curl http://localhost:8000/routes
       ```

   2. Send the request with expected output:

        ```json
        [
          {
            "Id": "LHR-JFK",
            "Origin": "LHR",
            "Destination": "JFK",
            "AvgDuration": 470
          },
          {
            "Id": "LHR-SFO",
            "Origin": "LHR",
            "Destination": "SFO",
            "AvgDuration": 660
          },
          {
            "...omitted...": "..."
          },
          {
            "Id": "LHR-LAX",
            "Origin": "LHR",
            "Destination": "LAX",
            "AvgDuration": 675
          }
        ]
        ```

    <br/>

3. Test the `Get a specific KongAir route by ID` Endpoint:

    <br/>

   **Using Insomnia**

    1. In Insomnia, navigate to where the collection has been imported, then navigate to the `/routes/{id}` endpoint; 
       click on try it out and provide `LHR-SIN` in the `id` field and then execute

    2. Send the request to receive the following output:

       ```json
        {
          "avg_duration": 660,
          "destination": "SIN",
          "id": "LHR-SIN",
          "origin": "SIN"
        }
       ```

    <br/>

   **Using cURL**

    1. Run the command below in the terminal:

        ```shell
        curl http://localhost:8000/routes
        ```

   2. Send the request with expected output:

       ```json
        {
          "avg_duration": 660,
          "destination": "SIN",
          "id": "LHR-SIN",
          "origin": "SIN"
        }
       ```

### Visualise the Generated Traffic

In this section, we will generate traffic and visualise it in the Grafana dashboard.

**Steps:**

1. Generate Traffic:

    <br/>

   **Using Insomnia**

   In Insomnia, navigate to where the collection has been imported, then submit requests to these endpoints multiple times:

    - `http://localhost:8000/routes`
    - `http://localhost:8000/routes/LHR-SIN`

    <br/>

   **Using cURL**

   Run the following shell command in your terminal to generate traffic:
      ```shell
        for i in {1..10}; do
          curl http://localhost:8000/routes
          curl http://localhost:8000/routes/LHR-SIN
          sleep 0.5
        done
      ```

    <br/>

2. View Metrics in Grafana

    - Open Grafana and navigate to the Kong dashboard

    - You should see metrics such as:
      - `Requests per service`
      - `Response statuses`
      - `Latencies`

    <br/>

3. View Logs in Grafana

    - Click `Explore > Loki`

    - Choose `label filters`: **service_name = kong-http-logs**
    
    - Click `Run query` to display the log entries

    - Click on any individual log to expand and view its details

    <br/>

4. View Traces in Grafana

    - In the log entry, click to expand it

    - Scroll to the bottom and click on the Jaeger link

    - This will open the corresponding trace, showing how much time was spent in each part of Kong during the request flow


Once traffic is visible in Grafana, move on to the next stage. In the following section, we will simulate system 
failures by injecting faults into the environment to observe how it behaves under failure conditions.

---

## Setup Failure Simulation

In this section, simulated failures and delays will be applied to the services in order to test the resilience of the
Kong Gateway; faults will be injected to simulate failures.

### Simulate Failure Configuration

Simulate errors using the [`Request Termination Plugin`](https://docs.konghq.com/hub/kong-inc/request-termination/)
Sending a request to this endpoint will respond with a `503 Service Unavailable` status, imitating a down service:

1. Add the `Request Termination` Plugin to the Routes Service. Update the [**platform/plugins.yaml**](./platform/plugins.yaml) 
   file to enable the plugin:

    ```yaml
    - config:
        message: Service Unavailable
        status_code: 503
      enabled: true
      name: request-termination
      service: routes-service
    ```

2. Apply the Configuration:

   Deploy the `request-termination` plugin configuration to the Gateway using the [**deploy-gateway.sh**](./deploy-gateway.sh) script.

3. Test the `Get Routes` endpoint:

    <br/>

   **Using Insomnia**

    1. In Insomnia, navigate to where the collection has been imported, then navigate to the `/routes` endpoint.
       Run the request which will return an error.

    2. Send the request to receive the following output:

       ```text
       Service Unavailable
       ```

    <br/>

   **Using cURL**

   1. Run the command below in the terminal:

       ```shell
       curl http://localhost:8000/routes
       ```

   2. Send the request with expected output:

       ```text
       Service Unavailable
       ```

       The response will be a `503 Service Unavailable`

    <br/>

4. Remove the Plugin After Testing:

    - Disable the plugin configuration from [**platform/plugins.yaml**](./platform/plugins.yaml) by setting the flag `enabled: false`

    - Reapply the configuration using the approach in Step 2

---

## Enhancing API Resilience

In this section, the Kong Gateway's resilience will be enhanced through the application of plugins and configurations,
which in turn will enable the Gateway to **better handle failures and improve performance.**

### Applying the Upstream Redirect Pattern

Whilst there is no specific Kong plugin to enable this common software pattern, known as circuit-breaking, we can
simulate this behaviour using health checks and load balancing.

#### Objective(s)

- Prevent cascading failures by stopping requests to an unhealthy upstream service

#### Plugin(s) used

- None; this is native Kong Gateway functionality

#### Guidance Steps

1. Configure Health Checks for the Routes Service:

   Update [**platform/upstream.yaml**](./platform/upstream.yaml) to include the below configuration:

   ```yaml
    _format_version: "3.0"
    upstreams:
    - name: routes.kongair
      algorithm: round-robin
      targets:
      - tags:
        - resiliency
        target: routes.kongair:8080
        weight: 100
      hash_fallback: none
      hash_on: none
      hash_on_cookie_path: "/"
      healthchecks:
        active:
          concurrency: 10
          healthy:
            http_statuses: [200, 302]
            interval: 5
            successes: 5
          http_path: "/health"
          https_verify_certificate: true
          timeout: 1
          type: http
          unhealthy:
            http_failures: 5
            http_statuses: [404, 429, 500, 501, 502, 503, 504, 505]
            interval: 5
            tcp_failures: 5
            timeouts: 0
        passive:
          healthy:
            http_statuses: [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 305, 306, 307, 308]
            successes: 80
          type: http
          unhealthy:
            http_failures: 5
            http_statuses: [429, 500, 503]
            tcp_failures: 5
            timeouts: 5
        threshold: 0
      slots: 10000
      tags:
      - resiliency
      use_srv_name: false
   ```

2. Apply the Configuration:

   Deploy the `upstream` configuration to the Gateway using the [**deploy-gateway.sh**](./deploy-gateway.sh) script.

3. Simulate Upstream Failure:

    - Stop the `kongair-routes` container:

      ```shell
      docker stop kongair-routes
      ```

4. Test the Circuit Breaker Behaviour with the `Get Routes` Endpoint:

   **Using Insomnia**

   In Insomnia, navigate to where the collection has been imported, then navigate to the `/routes` endpoint. Run the request which will return an error.

   **Using cURL**

   Run the command below in a terminal:

   ```shell
   curl http://localhost:8000/routes
   ```

   Expected Behaviour:

    - Kong will return an error without attempting to connect to the unhealthy upstream

5. Restart the Microservice:

   ```shell
   docker start kongair-routes
   ```

   Once the microservice is back up move on to the next section, it may take a few seconds to detect the change by Kong Gateway.

### Configuring Retries and Timeouts

In this section, the Kong Gateway configuration will be updated to contain configuration that will enable the `Retry`
and `Timeout` functionalities.

#### Objective(s)

- Configure Kong to retry failed requests and set appropriate timeouts

#### Plugin(s) used

- None - native functionality

#### Guidance Steps

1. Configure `retries` and the different `timeout` durations; each number is in `milliseconds`.

   Update the [**defaults.yaml**](./platform/defaults.yaml) to include the below configuration which will
   set the `connect`, `write`, and `read` timeouts to 1000, 2000, and 3000 respectively; set `retries` equal to 2:

   ```yaml
   _info:
     defaults:
       service:
         connect_timeout: 1000
         read_timeout: 3000
         retries: 2
         write_timeout: 2000
   ```

2. Apply the Configuration:
    
   Deploy the updated `defaults` configuration to the Gateway using the [**deploy-gateway.sh**](./deploy-gateway.sh) script.
    
3. Simulate artificial delays in the upstream service to test Kong’s retry and timeout handling:

    - In the [**docker-compose.yaml**](./docker-compose.yaml) file find the `kongair-routes` service:

     ```yaml
       kongair-routes:
         container_name: ${KONG_MS_CONTAINER_NAME}
         hostname: routes.kongair
         restart: on-failure
         image: ${KONG_MS_IMAGE_REGISTRY}/${KONG_MS_IMAGE_NAME}:${KONG_MS_IMAGE_TAG}
    ```

    - Use the image with the incremented tag, e.g. `image: <REGISTRY>/kongair-routes:ws-delays-<DATE>`, and remove/comment out the existing

    - Run the [**deploy-gateway.sh**](./deploy-gateway.sh) script to redeploy the `kongair-routes` service that now includes a 10-second delay.

4. Test the Configuration with the `Get Routes` Endpoint:

   **Using Insomnia**

   In Insomnia, navigate to where the collection has been imported, then navigate to the `/routes` endpoint.
   Run the request which will return an error.

   **Using cURL**

   Run the command below in a terminal:

   ```shell
   curl http://localhost:8000/routes
   ```

   Expected Behaviour:

    - Kong will return a timeout response within 3 seconds without forwarding the request to the upstream service
    - If the response time exceeds the read timeout, Kong will retry the request based on the retry count field number
    - Expected error response: `504 Gateway Time-out`
       ```json
        {
          "message": "The upstream server is timing out",
          "request_id": "c21ff94651edee784ae55853cc8b3e71"
        }
       ```

5. Rollback the Microservice's image to the previous tag i.e. `kongair-routes:ws-<DATE>`:

   - In the [**docker-compose.yaml**](./docker-compose.yaml) file, navigate to the `kongair-routes` service again:

   ```yaml
    kongair-routes:
      image: <REGISTRY>/kongair-routes:ws-delays-<DATE>
      container_name: kongair-routes
      hostname: routes.kongair
      restart: on-failure
      networks:
        - kong-net
      ports:
        - "5053:80"
    ```

    - Use the previous image, e.g. `image: <REGISTRY>/kongair-routes:ws-<DATE>`, and remove/comment out the incremented image version

    - Run the [**deploy-gateway.sh**](./deploy-gateway.sh) script to redeploy the kongair-routes 1.1 service that now does not include a 10-second delay.

### Implement Rate Limiting

Here the `Rate-Limting Advanced` plugin will be applied to the gateway where we will set up additional configuration to
stop too many inbound requests from overwhelming the system.

#### Objective(s)

- Protect upstream services by limiting the number of requests from clients

#### Plugin(s) used

- [`Rate Limiting Advanced`](https://docs.konghq.com/hub/kong-inc/rate-limiting-advanced/)

#### Guidance Steps

1. Enable the Rate Limiting Plugin:

   Update [**platform/plugins.yaml**](./platform/plugins.yaml):

   ```yaml
   - name: rate-limiting-advanced
     enabled: true
     config:
       hide_client_headers: false
       identifier: consumer
       limit:
       - 5
       namespace: example_namespace
       strategy: local
       sync_rate: -1
       window_size:
       - 30
   ```

2. Apply the Configuration:
 
   Deploy the `rate-limiting-advanced` plugin configuration to the Gateway using the [**deploy-gateway.sh**](./deploy-gateway.sh) script.

3. Test the Rate Limiting functionality applied:

   **Using Insomnia**

   In Insomnia, navigate to where the collection has been imported, then navigate to the `/routes` endpoint. Sending
   the request the first 5 times in the space of a minute will result in a `200` responses, but the 6th request will return
   a 429 error.

   **Using cURL**

   Run the command below in a terminal:

   ```shell
   for i in {1..6}; do
     curl -i http://localhost:8000/routes
   done
   ```

   Expected Behaviour:

   - The first 5 requests should succeed
   - The 6th request should return `429` Too Many Requests

4. Remove the Plugin after testing:

   - Disable the plugin configuration from [**platform/plugins.yaml**](./platform/plugins.yaml) by setting `enabled: false`

   - Reapply the configuration using the approach in Step 2

### Enable Caching to Reduce Load

In this section, the `Proxy Caching Advanced` plugin will be applied and help to reduce the amount of effort expended by
the Gateway when consumers request information from the same endpoints frequently.

#### Objective(s)

- Reduce load on upstream services by caching responses

#### Plugin(s) used

- [`Proxy Caching Advanced`](https://docs.konghq.com/hub/kong-inc/proxy-cache-advanced/)

#### Guidance Steps

1. Enable the Proxy Caching Plugin:

   Update the [**platform/plugins.yaml**](./platform/plugins.yaml) with the below configuration:

   ```yaml
   - name: proxy-cache-advanced
     enabled: true
     config:
       cache_ttl: 30
       content_type:
       - application/json; charset=UTF-8
       request_method:
       - GET
       response_code:
       - 200
       strategy: memory
   ```

2. Apply the Configuration:

   Deploy the `proxy-caching-advanced` plugin configuration to the Gateway using the [**deploy-gateway.sh**](./deploy-gateway.sh) script.

3. Test the Caching functionality applied:

   **Using Insomnia**

   In Insomnia, navigate to where the collection has been imported, then navigate to the `/routes` endpoint. Running the
   request the first time will take longer than subsequent requests. The first request will take longer as it is
   fetching data from the upstream service, while subsequent requests will be served from the cache.

   **Using cURL**

   Run the below in a terminal:

   ```shell
   curl -i http://localhost:8000/routes
   curl -i http://localhost:8000/routes
   ```

   Expected Behaviour:

    - The first request fetches data from the upstream service - this is the only request that will take time
    - Subsequent requests within 30 seconds are served from the cache and thus return faster

   Verify via Response Headers:

    - Check the `X-Cache-Status` header; it should show `Miss` for the first request and `Hit` for all subsequent requests

4. Disable the plugin and apply the configuration using the approach outlined in Step 2

### Chaos Engineering Plugin

This custom plugin enables chaos engineering experiments to be configured on the Kong gateway.

The experiments supported are:

  - `Request latency`: introduce a latency into the request using the Gaussian distribution to simulate real-world lag spikes
  - `Connection aborts`: forcibly close the connection to the Kong gateway without a response
  - `Custom responses`: allow for custom responses to be generated

#### Chaos Engineering Configuration

1. Enable the Chaos Engineering Plugin:

   ```yaml
   - name: chaos-experiments
     enabled: true
     config:
       abort_request_probability: 0.25
       custom_response_probability: 0.5
       custom_response_status_codes: [400, 418, 502, 504]
       request_latency_correlation: 0.5
       request_latency_debug_header: X-Kong-Latency-Debug-Header
       request_latency_jitter_ms: 150
       request_latency_mean_ms: 250
       request_latency_probability: 0.75
   ```

2. Apply the Configuration:

   Deploy the `chaos engineering` plugin configuration to the Gateway using the [**deploy-gateway.sh**](./deploy-gateway.sh) script.

3. Test the Chaos functionality:

   ```shell
   for i in {1..10}; do
     curl http://localhost:8000/routes
     sleep 2
   done
   ```

   Expected Behaviour:

    - Every request will return different response message and status code

4. Disable the plugin and apply the configuration using the [**deploy-gateway.sh**](./deploy-gateway.sh) script referenced in Step 2

### Additional Plugins for API Resilience

The following plugins can further enhance API resilience but are not covered in this workshop due to time constraints.
Each of these plugins provides unique functionalities that can complement the configurations discussed above.

#### 1. Request Size Limiting Plugin

- Ensures that incoming requests do not exceed a predefined size
- Prevents payloads that are too large from overwhelming services
- Example configuration:
  ```yaml
  - name: request-size-limiting
    config:
      allowed_payload_size: 128
      require_content_length: false
  ```
- [`Documentation link`](https://docs.konghq.com/hub/kong-inc/request-size-limiting/) where you can find out more about this plugin.

#### 2. OpenAPI (OAS) Validation Plugin

- Validates incoming requests against an OpenAPI 3.1 specification
- Ensures compliance with the defined API schema, reducing the risk of invalid or malicious data
- Example configuration:
  ```yaml
  - name: oas-validation
    service: routes-service
    config:
      api_spec: <OAS FILE LOCATION>
  ```
- [`Documentation link`](https://docs.konghq.com/hub/kong-inc/request-validator/) where you can find out more about this plugin.

#### 3. JSON Threat Protection Plugin

- Protects against malicious JSON payloads
- Limits the depth, size, and structure of incoming JSON to prevent vulnerabilities
- Example configuration:
  ```yaml
  - name: json-threat-protection
    config:
      max_body_size: 10
      max_container_depth: 1
      max_object_entry_count: 2
      max_object_entry_name_length: 3
      max_array_element_count: 4
      max_string_value_length: 5
      enforcement_mode: block
      error_status_code: 400
      error_message: BadRequest
  ```
- [`Documentation link`](https://docs.konghq.com/hub/kong-inc/json-threat-protection/) where you can find out more about this plugin.

#### 4. Service Protection Plugin

- Limits the number of requests a service can handle in a defined time window
- Helps to prevent overloading and safeguarding of backend services
- Example Configuration:
  ```yaml
  - name: service-protection
    service: routes-service
    config:
      window_size:
      - 30
      window_type: sliding
      limit:
      - 5
      namespace: example_namespace
  ```
- [`Documentation link`](https://docs.konghq.com/hub/kong-inc/service-protection/) where you can find out more about this plugin.

#### 5. Injection Protection Plugin

- Defends against SQL injection, XSS, and other common web vulnerabilities by sanitising input
- Ideal for APIs exposed to untrusted or public traffic
- Example configuration:
  ```yaml
  - name: injection-protection
    config:
      injection_types:
      - sql
      locations:
      - path_and_query
      enforcement_mode: block
      error_status_code: 400
      error_message: Bad Request
  ```
- [`Documentation link`](https://docs.konghq.com/hub/kong-inc/injection-protection/) where you can find out more about this plugin.

#### 6. Bot Detection Plugin

- Identifies and blocks automated traffic from bots
- Prevents abuse and preserves resources for legitimate users
- Example configuration:
  ```yaml
  - name: bot-detection
    service: routes-service
    config:
      deny:
      - "hello-world"
  ```
- [`Documentation link`](https://docs.konghq.com/hub/kong-inc/bot-detection/) where you can find out more about this plugin.

#### 7. Request Validator Plugin

- Validates incoming request data against user-defined schemas
- Protects APIs from malformed or malicious input
- Example configuration:
  ```yaml
  - name: request-validator
    config:
      body_schema: '[{"name":{"type": "string", "required": true}}]'
  ```
- [`Documentation link`](https://docs.konghq.com/hub/kong-inc/request-validator/) where you can find out more about this plugin.

---

## Case Studies

### Case Study 1: Overview

This case study highlights how Kong Gateway was instrumental in mitigating a Distributed Denial of Service (DDoS) attack
targeting an account-creation API. The attack exploited the API in order to overload a shared database, leading to
degraded service across an entire region. Despite not having a dedicated Web Application Firewall (WAF), Kong Gateway’s
flexibility, extensibility, and rapid response capabilities demonstrated its effectiveness in addressing evolving threats.

### Case Study 1: Key Mitigation Measures and Insights

#### 1. IP-Based Rate Limiting

The first response involved implementing the `rate-limiting-advanced` plugin in order to restrict the number of requests
per IP. This measure provided temporary relief but was quickly circumvented as the attacker distributed the attack across
multiple IPs. This demonstrated the importance of layered defenses when handling threats that can adapt over time.

#### 2. Traffic Analysis and Dynamic Blocking

The `file-log` plugin was enabled on the Gateway in order to analyse real-time inbound traffic and help identify
patterns; the team detected a suspicious user-agent string in these requests. Using the `bot-detection` plugin, traffic
with the identified user-agent was blocked which significantly reduced system load. This showcased the value of real-time
monitoring and adaptive defense mechanisms.

#### 3. Custom blocking using patterns

Further analysis revealed a consistent malicious cookie signature. A custom `pre-function` script was created to block
requests containing this cookie pattern. This demonstrated how Kong Gateway’s extensibility allows for rapid, tailored
responses to specific attack vectors.

#### 4. Geographical Restrictions

A custom `pre-function` (integrated with a third-party geolocation service) restricted traffic to approved regions. This
approach reduced unnecessary load and in the end limited the scope of the attack. Geo-restrictions proved to be a
valuable layer in the defense strategy.

#### 5. Automated Verification with reCAPTCHA

To counter automated malicious requests, another `pre-function` was introduced to validate reCAPTCHA tokens. This one
ensured that only legitimate users could access the API whilst at the same time blocking bots, adding yet another
automated protection layer.

### Case Study 1: Lessons Learned

- **Adaptive defense**: The attackers' evolving tactics required continuous analysis and rapid adaptation of countermeasures
- **Custom solutions**: Kong Gateway’s extensibility (through plugins and pre-functions) enabled for custom defenses even
  without a WAF in place
- **Layered security is essential**: While Kong Gateway provided a robust response, making use of a dedicated WAF alongside
  it would further enhance defences against threats like these

### Case Study 1: API Resiliency with Kong Gateway

Overall, this case study demonstrates how Kong Gateway strengthens API resiliency through a combination of features
and strategies:

- **Granular Traffic Control**: Plugins such as the `rate-limiting-advanced` allow for precise control over inbound request
  thresholds/limitations
- **Dynamic Threat Mitigation**: Logging tools such as `file-log` provide visibility, enabling adaptive responses via
  plugins and pre-functions
- **Geographical Access Restrictions**: Geo-IP filtering can limit traffic to specific regions, reducing exposure
- **Automated Protections**: Plugins like `bot-detection` and custom reCAPTCHA validation defend against automated attacks
- **Scalable and Extensible Defenses**: Kong Gateway’s flexibility supports the ongoing development of new defenses to meet
  evolving threats

### Case Study 1: Conclusion

This case study explains the importance of leveraging Kong Gateway as a central component in API security strategies.
Its combination of plugins, logging tools and custom `pre-functions` makes it a versatile and powerful tool for mitigating
cyber threats. When complemented by a WAF, these capabilities form a robust, layered defense against sophisticated API
attacks. Organisations can rely on Kong Gateway to build a scalable, flexible and adaptive API resiliency framework,
which will ensure service continuity even in the face of ever-evolving cyberattacks.

---

## Best Practices

### 1. Design for Failure

#### Overview

In distributed systems failures are inevitable. Designing for failure involves being able to anticipate potential points
of failure and effectively implement mechanisms that can handle them gracefully.

#### Recommendations

##### Upstream Redirection

- Implement upstream redirection, also known as circuit breakers, within Kong in order to prevent cascading failures 
  when an upstream service becomes non-responsive

- Use Kong’s health check functionality and load balancing features to route traffic away from unhealthy services

##### Health Checks

- Configure active health checks to monitor the availability of upstream services

- Set appropriate threshold for marking services as healthy (or unhealthy)

##### API-level design pattern considerations:

- Idempotency - particularly important within financial services to ensure delivery of a request with retry functionality
  without being processed multiple times (Note: this is not within the scope of this workshop)

- Fallback mechanisms - default responses when services are unavailable

#### Benefits

- Helps to prevent overloading services which have failed

- Improves overall system stability

- Enhances availability through infrastructure redundancy

### 2. Optimise Timeouts and Retries

#### Overview

Properly configured timeout and retry thresholds can prevent requests from hanging indefinitely, and helps to balance
the load on upstream services.

#### Recommendations

##### Timeouts

- Set connection, read, and write timeouts based on the expected response times of upstream services

- Avoid overly long timeouts which can tie up resources unless required as part of an architecture design decision

##### Retries

- Configure an appropriate/reasonable threshold of retries in order to most effectively handle transient failures

- Be cautious with high retry counts as these can amplify load on already failing services

#### Benefits

- Improves system responsiveness

- Reduce resource consumption during times of failure

### 3. Control Traffic with Rate-Limiting

#### Overview

Rate limiting functionality has been built to protect upstream services from dealing with excessive load, whether due to
traffic spikes in customer demand or due to malicious activity from an unknown party.

#### Recommendations

##### Backend Protection

- Implement the Rate Limiting Advanced plugin to protect backend services from traffic spikes

##### Usage Limits Transparency

- Include rate limit headers in responses to let clients know their usage and limits

##### Subscription Limitations

- Use of the Rate Limiting Advanced plugin to enforce quotas for each consumer (services and routes can also have these
  limitations applied to them)

- Ensures fair usage of the backend services

#### Benefits

- Protects upstream services from demand overload, e.g. customer influxes, Distributed Denial of Service (DDOS) attacks

- Enforces usage policies and Service-Level Agreements (SLAs)

### 4. Reduce Load with Caching

#### Overview

Caching reduces load on upstream services by serving repeated requests directly from the gateway, without re-querying 
the upstream.

#### Recommendations

##### Proxy Cache Plugin

- Implement the Proxy Cache Advanced plugin to cache responses

- Configure cache keys, TTLs and invalidation rules

##### Caching Strategies

- Use memory caching for quick retrieval of information

- Consider persistent caching by using a system like Redis for larger datasets

### Benefits

- Decreases latency of responses

- Reduces load on upstream services for repetitively accessed information

- Improves the overall user experience with faster response times

### 5. Enhance Observability

#### Overview

Observability is critical for understanding system behaviour, diagnosing issues as well as ensuring that a systems’
performance metrics meet Service Level Agreements (SLAs).

#### Recommendations

##### Metrics collection

- Enable the Prometheus plugin to collect detailed metrics

- Collect system metrics on attributes such as:

    - Request rates

    - Latencies

    - Error rates

    - Upstream health

##### Logging

- Configure structured logging for easier analysis

- The use of log aggregation tooling to centralise logs

##### Dashboards

- The use of observability tools, like Grafana, to visualise metrics

- Set up alerting systems at the infrastructure and API levels to proactively identify and resolve issues:

    - Infrastructure Alerting: Monitor system resources like CPU, memory and memory usage

    - API-Level Alerting: Track API performance indicators such as error rates and response times

#### Benefits

- Improves issue detection and resolution

- Facilitates capacity planning

- Ensures high observability standards across both infrastructure and application systems

### 6. Secure Deployments

#### Overview

Security is integral to reliability; a secure deployment reduces the risk of breaches that can lead to downtime or
data loss.

#### Recommendations

##### Mutual TLS (mTLS)

- The use of mTLS to secure communication between the Data Plane and the Control Plane

- The regular rotation of certificates

##### Authentication & Authorisation

- Implementation of proper auth mechanisms such as:

    - API Keys

    - JSON Web Tokens (JWTs)

    - OAuth 2.0

##### Access Control Lists (ACLs) and Role-Based Access Control (RBAC) to control user access

- Input Validation

- Sanitise inputs in order to prevent injection attacks

- Use of plugins such as Request Transformer to enforce input policies

#### Benefits

- Protects sensitive data

- Ensures compliance with security standards

---

## Conclusion

API resilience is essential for maintaining robust and reliable services in the face of failures and unpredictable
traffic patterns. By leveraging Kong Gateway's native capabilities and advanced plugins, you can build systems that
withstand partial outages, fail gracefully, and recover quickly. With proper configurations, such as circuit breakers,
retries, rate limiting, and caching, coupled with enhanced observability and security, your APIs can deliver consistent
performance and exceptional user experiences.

Start implementing these strategies today to future-proof your API infrastructure.

## Troubleshooting Common Issues

For connectivity issues please see the [**Troubleshooting document**](./troubleshooting.md) for common issues.

Alternatively, access our [`Support Page`](https://support.konghq.com/support/s/knowledge) for FAQs as well as the option 
to raise your own queries with our Support Team.

---

## Environment Clean-Up Workflow

This workflow provides a safer and more controlled approach to cleaning up your environment, ensuring essential
resources are not removed unintentionally.

### 1. Stop Services & Remove Related Docker Resources

Stop all running services and remove associated containers, networks, and volumes for the current project:

```shell
docker-compose down --volumes --remove-orphans
```

### 2. Remove Unused Containers and Networks

Perform a safe clean-up of unused containers and networks without affecting other resources:

- Remove all stopped containers:

  ```shell
  docker container prune -f
  ```

- Remove unused networks:

  ```shell
  docker network prune -f
  ```

### 3. (Optional) Remove Unused Volumes

To clean up volumes, list and remove only unused ones:

- List unused volumes:

  ```shell
  docker volume ls -qf dangling=true
  ```

- Remove unused volumes selectively:

  ```shell
  docker volume rm $(docker volume ls -qf dangling=true)
  ```

### 4. Clean Up Local Files

Remove files generated by the project safely using `git clean`:

- Preview untracked files and directories to be removed:

  ```shell
  git clean -ndx
  ```

- Clean untracked files and directories:

  ```shell
  git clean -fdx
  ```

- Exclude specific files or directories from deletion:

  ```shell
  git clean -fdx --exclude=<file_or_dir_to_keep>
  ```

Alternatively, run the below to delete all untracked & unstaged files in one fell swoop

```shell
for f in $({git diff --name-only ; git ls-files --other --exclude-standard ; } | grep -v .idea); do
  if [[ -f $f ]]
    rm -rf ./$f
  fi
done
```

### 5. Verify the Clean-Up

After performing the clean-up, verify the environment to ensure no unwanted artifacts remain:

- Check for running containers:

  ```shell
  docker ps -a
  ```

- List remaining images, volumes, and networks:

  ```shell
  docker images
  docker volume ls
  docker network ls
  ```

- Check your working directory:

  ```shell
  git status
  ```

---

Congratulations! You have successfully completed the API Resilience Workshop. If you have any questions or need further
assistance, please reach out to the workshop facilitators.

Copyright - Professional Services @ Kong Inc.

---
