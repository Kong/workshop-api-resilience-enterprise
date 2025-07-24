# Troubleshooting

## Enterprise Control Plane and Data Plane Connectivity Issues

If any failures occur, such as the Control Plane being unable to connect to the PostgreSQL database, consider the following potential issues:

1. **Database Connection Issues**
   Error: `Failed to connect to PostgreSQL`
    - Ensure that the PostgreSQL container is running:
      ```shell
      docker-compose logs db
      ```
    - Verify that the `KONG_DATABASE` environment variable is set to `postgres`
    - Check if the correct database credentials (username, password, host) are set in the `.env` file or `docker-compose.yaml`
    - Ensure PostgreSQL is allowing external connections (e.g., `listen_addresses = '*'` in `postgresql.conf`)

2. **Control Plane Not Booting**
   Error: `Could not start Kong Control Plane`
    - Run:
      ```shell
      docker-compose logs control-plane
      ```
    - Ensure that the Kong container is able to locate the Kong binaries in `PATH`
    - Check if the license is set correctly using the `KONG_LICENSE_DATA` variable or a mounted license file
    - Verify that the database migration has been completed by running:
      ```shell
      kong migrations bootstrap
      ```
    - Make sure the Control Plane is listening on the correct ports (such as port `8005` for the cluster control plane API)

3. **Data Plane Unable to Connect to Control Plane**
   Error: `Failed to join Control Plane`
    - Run:
      ```shell
      docker-compose logs data-plane
      ```
    - Ensure that the Control Plane is reachable from the Data Plane on the correct port (default: `8005`)
    - Verify that the `KONG_CLUSTER_CONTROL_PLANE` environment variable is correctly pointing to the Control Plane’s address
    - Ensure the `KONG_CLUSTER_CERT` and `KONG_CLUSTER_CERT_KEY` environment variables are properly set for mTLS

4. **Network and Port Binding Issues**
   Symptoms: Services not reachable from your host machine
    - Check if ports are bound:
      ```shell
      netstat -tulnp | grep 8005
      ```
    - If another process is using the same ports, adjust them in `docker-compose.yaml` or stop the conflicting process

5. Permission Issues
   Error: `Permission denied` when starting containers
    - Verify that your user has permission to access mounted volumes (e.g., run `chmod -R 777 /your/data/directory`)
    - If using macOS or Windows with Docker Desktop, check file sharing settings
    - If using SELinux, add the `:z` flag to mounted volumes

6. **Docker Compose Issues**
   Error: `Command 'docker-compose' not found`
    - Ensure that `docker-compose` (or `docker compose` for newer versions) is installed and accessible in `PATH`
      Error: `Docker daemon not running`
    - Start Docker:
      ```shell
      sudo systemctl start docker
      ```
    - Confirm your user is in the `docker` group:
      ```shell
      sudo usermod -aG docker $USER
      ```

7. **License Issues**
   Error: `invalid license`
    - Verify that `KONG_LICENSE_DATA` is correctly set in your environment
    - Ensure that the license file is mounted correctly if you are using a file-based approach

8. **Memory and Resource Constraints**
   Symptoms: Containers restarting frequently
    - Check resource usage:
      ```shell
      free -m
      docker stats
      ```
    - Increase Docker’s allocated memory (in Docker Desktop settings or similar) if you’re running in a constrained environment

In the case that the error or issue encountered is not listed, please let a member of the Kong team know, or contact the Kong Support team

---

## Monitoring Troubleshooting

1. Authentication Errors 
    Error: `401 Unauthorized` or `403 Forbidden`
    - Ensure that the Admin API token is correctly set:
    ```shell
    echo $KONG_ADMIN_TOKEN
    ```
    - If empty, re-run:
    ```shell
    export KONG_ADMIN_TOKEN=<YOUR_ADMIN_API_TOKEN>
    ```
    - Verify that the token has the necessary RBAC permissions to make changes via `deck sync`

2. Connectivity Issues
    Error: `Failed to connect to <CONTROL_PLANE_HOST>`
    - Verify that the Control Plane is reachable from your machine:
    ```shell
    curl -H "Kong-Admin-Token: $KONG_ADMIN_TOKEN" https://<CONTROL_PLANE_HOST>:8001/status
    ```
    - If the request fails:
      - Ensure that `<CONTROL_PLANE_HOST>` is correct and reachable
      - Confirm that port `8001` is open (use `netstat -tulnp | grep 8001`)
      - If using TLS, change `8001` to `8444` in the `--kong-addr` flag

3. Configuration Not Applying
    Symptoms: No changes reflected after running `deck sync`
    - Run:
    ```shell
      deck diff --kong-addr https://<CONTROL_PLANE_HOST>:8001 --headers "Kong-Admin-Token:$KONG_ADMIN_TOKEN"
      ```
    - If no changes are detected, check:
      - Your configuration files for missing tags (`resiliency`)
      - Whether the Admin API token has the necessary write permissions

4. Kong Admin API Unreachable
    Error: `Could not resolve host: <CONTROL_PLANE_HOST>`
    - Ensure the hostname/IP of the Control Plane is correct
    - If using Docker, check whether the container’s hostname matches the one in your `deck sync` command
    - If running Kong on Kubernetes, ensure your Control Plane’s Admin API is exposed via a Kubernetes service
