-- This software is copyright Kong Inc. and its licensors.
-- Use of the software is subject to the agreement between your organization
-- and Kong Inc. If there is no such agreement, use is governed by and
-- subject to the terms of the Kong Master Software License Agreement found
-- at https://konghq.com/enterprisesoftwarelicense/.
-- [ END OF LICENSE 0867164ffc95e54f04670b5169c09574bdbd9bba ]

local Utils = {}

-- Generates a random number using a Gaussian distribution with the given mean, jitter, correlation.
-- returns the calculated latency along with the random number used to generate the latency.
-- the random number number can be passed into subsequent invocations to allow the next number to be correlated with the previous invocation.
function Utils:generate_latency(mean, jitter, correlation, last_rnd)
  last_rnd = last_rnd or 0.5
  local rnd = math.random() * (1 - correlation) + (last_rnd * correlation)
  return ((rnd * (2 * jitter)) + mean) - jitter, rnd
end

return Utils
