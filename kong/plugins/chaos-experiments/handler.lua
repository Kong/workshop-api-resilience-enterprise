-- This software is copyright Kong Inc. and its licensors.
-- Use of the software is subject to the agreement between your organization
-- and Kong Inc. If there is no such agreement, use is governed by and
-- subject to the terms of the Kong Master Software License Agreement found
-- at https://konghq.com/enterprisesoftwarelicense/.
-- [ END OF LICENSE 0867164ffc95e54f04670b5169c09574bdbd9bba ]

local utils = require "kong.plugins.chaos-experiments.utils"
local cache = require "kong.plugins.chaos-experiments.cache"

local CACHED_LATENCY_IDENTIFIER = "latency"

-- Currently only local storage is supported
local CACHE_IMPL = "local"
local NGINX_ABORT_CODE = 444
local DEFAULT_RESPONSE_MESSAGES = {
  [100] = "Continue",
  [101] = "Switching Protocols",
  [102] = "Processing",
  [103] = "Early Hints",
  [200] = "OK",
  [201] = "Created",
  [202] = "Accepted",
  [203] = "Non-Authoritative Information",
  [204] = "No Content",
  [205] = "Reset Content",
  [206] = "Partial Content",
  [207] = "Multi-Status",
  [208] = "Already Reported",
  [226] = "IM Used",
  [300] = "Multiple Choices",
  [301] = "Moved Permanently",
  [302] = "Found",
  [303] = "See Other",
  [304] = "Not Modified",
  [305] = "Use Proxy",
  [307] = "Temporary Redirect",
  [308] = "Permanent Redirect",
  [400] = "Bad Request",
  [401] = "Unauthorized",
  [402] = "Payment Required",
  [403] = "Forbidden",
  [404] = "Not Found",
  [405] = "Method Not Allowed",
  [406] = "Not Acceptable",
  [407] = "Proxy Authentication Required",
  [408] = "Request Timeout",
  [409] = "Conflict",
  [410] = "Gone",
  [411] = "Length Required",
  [412] = "Precondition Failed",
  [413] = "Content Too Large",
  [414] = "URI Too Long",
  [415] = "Unsupported Media Type",
  [416] = "Range Not Satisfiable",
  [417] = "Expectation Failed",
  [421] = "Misdirected Request",
  [422] = "Unprocessable Content",
  [423] = "Locked",
  [424] = "Failed Dependency",
  [425] = "Too Early",
  [426] = "Upgrade Required",
  [427] = "Unassigned",
  [428] = "Precondition Required",
  [429] = "Too Many Requests",
  [431] = "Request Header Fields Too Large",
  [451] = "Unavailable For Legal Reasons",
  [500] = "Internal Server Error",
  [501] = "Not Implemented",
  [502] = "Bad Gateway",
  [503] = "Service Unavailable",
  [504] = "Gateway Timeout",
  [505] = "HTTP Version Not Supported",
  [506] = "Variant Also Negotiates",
  [507] = "Insufficient Storage",
  [508] = "Loop Detected",
  [511] = "Network Authentication Required"
}

local plugin = {
  PRIORITY = 0,
  VERSION = "0.1"
}

local function request_latency_handler(conf)
  local trigger = conf.request_latency_probability > 0
      and math.random() <= conf.request_latency_probability
      and (conf.request_latency_mean_ms > 0 or conf.request_latency_jitter_ms > 0)

  if (trigger) then
    local last_rnd = cache[CACHE_IMPL]:get(conf, CACHED_LATENCY_IDENTIFIER)
    local latency, rnd = utils:generate_latency(conf.request_latency_mean_ms, conf.request_latency_jitter_ms,
      conf.request_latency_correlation, last_rnd)

    if (#conf.request_latency_debug_header > 0) then
      kong.response.set_header(conf.request_latency_debug_header, string.format("%d", latency))
    end
    cache[CACHE_IMPL]:set(conf, CACHED_LATENCY_IDENTIFIER, rnd)
    ngx.sleep(latency / 1000)
  end
  return trigger
end

local function abort_request_handler(conf)
  local trigger = conf.abort_request_probability > 0 and math.random() <= conf.abort_request_probability

  if (trigger) then
    kong.response.exit(NGINX_ABORT_CODE)
  end
  return trigger
end

local function custom_response_handler(conf)
  local trigger = conf.custom_response_probability > 0 and math.random() <= conf.custom_response_probability

  if (trigger) then
    local status = conf.custom_response_status_codes[math.random(#conf.custom_response_status_codes)]
    local headers = {}
    local content = ""

    if (#conf.custom_response_content_type > 0) then
      headers["Content-Type"] = conf.custom_response_content_type
    end

    if (#conf.custom_response_body_template > 0) then
      content = string.gsub(conf.custom_response_body_template, "{{status}}", status)
      content = string.gsub(content, "{{message}}", DEFAULT_RESPONSE_MESSAGES[status] or ("Error " .. status))
    end

    kong.response.exit(status, content, headers)
  end
  return trigger
end

function plugin:access(conf)
  request_latency_handler(conf)
  local abort = abort_request_handler(conf)
  if not (abort) then abort = custom_response_handler(conf) end
end

return plugin
