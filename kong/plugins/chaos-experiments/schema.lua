-- This software is copyright Kong Inc. and its licensors.
-- Use of the software is subject to the agreement between your organization
-- and Kong Inc. If there is no such agreement, use is governed by and
-- subject to the terms of the Kong Master Software License Agreement found
-- at https://konghq.com/enterprisesoftwarelicense/.
-- [ END OF LICENSE 0867164ffc95e54f04670b5169c09574bdbd9bba ]

local typedefs = require "kong.db.schema.typedefs"
local PLUGIN_NAME = "chaos-experiments"
-- Max allowed latency is 10 minutes
local MAX_LATENCY = 10 * 60 * 1000
local schema = {
  name = PLUGIN_NAME,
  fields = {
    {
      consumer = typedefs.no_consumer
    },
    {
      protocols = typedefs.protocols_http
    },
    {
      config = {
        type = "record",
        fields = {
          {
            request_latency_probability = {
              type = "number",
              default = 0.0,
              between = { 0, 1 }
            }
          },
          {
            request_latency_mean_ms = {
              type = "integer",
              default = 0,
              between = { 0, MAX_LATENCY }
            }
          },
          {
            request_latency_jitter_ms = {
              type = "integer",
              default = 0,
              between = { 0, MAX_LATENCY }
            }
          },
          {
            request_latency_correlation = {
              type = "number",
              default = 0.5,
              between = { 0, 1 }
            }
          },
          {
            request_latency_debug_header = {
              type = "string",
              default = "X-Kong-Chaos-Latency",
              required = false,
              len_min = 0
            }
          },
          {
            abort_request_probability = {
              type = "number",
              default = 0.0,
              between = { 0, 1 }
            }
          },
          {
            custom_response_probability = {
              type = "number",
              default = 0.0,
              between = { 0, 1 }
            }
          },
          {
            custom_response_status_codes = {
              type = "array",
              default = {},
              elements = {
                type = "integer",
                between = { 100, 599 }
              }
            }
          },
          {
            custom_response_content_type = {
              type = "string",
              default = "application/json; charset=utf-8",
              required = false,
              len_min = 0
            }
          },
          {
            custom_response_body_template = {
              type = "string",
              default = "{ \"code\": \"{{status}}\", \"message\": \"{{message}}\" }",
              required = false,
              len_min = 0
            }
          }
        },
        entity_checks = {
          {
            conditional = {
              if_field = "custom_response_probability",
              if_match = {
                gt = 0
              },
              then_field = "custom_response_status_codes",
              then_match = {
                required = true,
                len_min = 1
              }
            }
          }
        }
      }
    }
  }
}

return schema
