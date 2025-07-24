#!/bin/sh
set -e

BASE_DIR=$(dirname "$0")

if [ ! -d "${BASE_DIR}" ]; then
  echo "Setting up directories: "
  mkdir -p "${BASE_DIR}/deck"
fi

echo "Starting deck operations..."
echo ${BASE_DIR}
echo "Step 1: Converting OpenAPI Specification to 'kong-routes.yaml'..."
deck file openapi2kong --spec "${BASE_DIR}/kong-air/routes/open-api.yaml" \
  -o "${BASE_DIR}/kong-air/routes/kong-routes.yaml"

echo "Step 2: Adding 'resiliency' tag to Kong routes..."
deck file add-tags resiliency \
  -s "${BASE_DIR}/kong-air/routes/kong-routes.yaml" \
  -o "${BASE_DIR}/kong-air/routes/kong-routes.yaml"

echo "Step 3: Adding 'resiliency' tag to platform 'defaults.yaml', 'plugins.yaml', 'retries-timeouts.yaml', and 'upstream.yaml'..."
deck file add-tags resiliency -s "${BASE_DIR}/platform/defaults.yaml" -o "${BASE_DIR}/platform/defaults.yaml"
deck file add-tags resiliency -s "${BASE_DIR}/platform/plugins.yaml" -o "${BASE_DIR}/platform/plugins.yaml"
deck file add-tags resiliency -s "${BASE_DIR}/platform/upstream.yaml" -o "${BASE_DIR}/platform/upstream.yaml"

echo "Step 4: Merging Kong routes and platform plugins into a single file..."
deck file merge "${BASE_DIR}/kong-air/routes/kong-routes.yaml" \
  "${BASE_DIR}/platform/defaults.yaml" \
  "${BASE_DIR}/platform/plugins.yaml" \
  "${BASE_DIR}/platform/upstream.yaml" \
   -o "${BASE_DIR}/deck/kong.yaml"


echo "Step 5: Synchronising the merged configuration with the gateway..."
if [ "${DECK_ADDR}" = "https://us.api.konghq.com" ]; then
  cd "${BASE_DIR}/deck"
  deck version
  deck gateway sync ${BASE_DIR}/deck/*.yaml \
    --konnect-addr "${DECK_ADDR}" \
    --konnect-control-plane-name "${DECK_KONNECT_CONTROL_PLANE_NAME}" \
    --konnect-token "${DECK_KONNECT_TOKEN}" \
    --select-tag resiliency
else
  deck gateway sync ${BASE_DIR}/deck/*.yaml \
    --kong-addr "${DECK_ADDR}" \
    --select-tag resiliency
fi

echo "Step 6: Displaying the final merged deck file..."
echo "---------------------------------------------------"
cat "${BASE_DIR}/deck/kong.yaml"
echo "---------------------------------------------------"

echo "***************************************************"
echo "*                                                 *"
echo "*       SETUP IS COMPLETE - READY TO KONG!        *"
echo "*                                                 *"
echo "***************************************************"