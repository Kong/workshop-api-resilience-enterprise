-- This software is copyright Kong Inc. and its licensors.
-- Use of the software is subject to the agreement between your organization
-- and Kong Inc. If there is no such agreement, use is governed by and
-- subject to the terms of the Kong Master Software License Agreement found
-- at https://konghq.com/enterprisesoftwarelicense/.
-- [ END OF LICENSE 0867164ffc95e54f04670b5169c09574bdbd9bba ]

local EMPTY_UUID = "00000000-0000-0000-0000-000000000000"
local shm = ngx.shared.kong

local function get_id_or_empty(id)
  if not id or id == ngx.null then
    id = EMPTY_UUID
  end
  return id
end

local get_cache_key = function(conf, identifier)
  conf = conf or {}
  local service_id = get_id_or_empty(conf.service_id)
  local route_id = get_id_or_empty(conf.route_id)
  return string.format("chaos-experiments-latency:%s:%s:%s", route_id, service_id, identifier)
end

local Impl = {}

function Impl:get(conf, identifier)
  local key = get_cache_key(conf, identifier)
  local value, err = shm:get(key)
  if err then
    return nil, err
  end
  return value

end

function Impl:set(conf, identifier, value)
  local key = get_cache_key(conf, identifier)
  local success, err = shm:set(key, value)
  if not (success) or err then
    kong.log.err("unable to cache value for key '", key, "': ", err)
  end
  return value
end

return Impl
