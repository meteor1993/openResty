-- local function close_redes( red )
--   if not red then
--     return
--   end
--   local ok, err = red:close()
--   if not ok then
--     ngx.say("close redis error:", err)
--   end
-- end

local function close_redes( red )
  if not red then
    return
  end
  -- 释放连接（连接池实现）
  local pool_max_idle_time = 10000 -- 毫秒
  local pool_size = 100 --连接池大小
  local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)
  if not ok then
    ngx.say("set keepalive error : ", err)
  end
end

local redis = require("resty.redis")

-- 创建实例
local red = redis:new()
-- 设置超时(毫秒)
red:set_timeout(2000)
-- 建立连接
local ip = "172.19.73.87"
local port = 6379
local ok, err = red:connect(ip, port)
if not ok then
  return
end
local res, err = red:auth("wsy@123456")
if not res then
  ngx.say("connect to redis error : ", err)
  return
end

red:init_pipeline()
red:set("msg1", "hello1")
red:set("msg2", "hello2")
red:get("msg1")
red:get("msg2")
local respTable, err = red:commit_pipeline()

-- 得到数据为空处理
if respTable == ngx.null then
  respTable = {}
end

-- 结果是按照执行顺序返回的一个table
for i, v in ipairs(respTable) do
  ngx.say("msg : ", v, "<br/>")
end

close_redes(red)