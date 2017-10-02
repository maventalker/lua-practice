local redis = require("resty.redis")
JSON = (loadfile "JSON.lua")()
--创建实例
local redis_instance = redis:new()
--设置超时（毫秒）
redis_instance:set_timeout(3000)
--建立连接
local host = "127.0.0.1"
local port = 6679
local ok, err = redis_instance:connect(host, port)
if not ok then
ngx.say("connect to redis error : ", err)
return close_redis(redis_instance)
end
local resp, err = redis_instance:eval("return redis.call('get', KEYS[1])", 1, "alibaba");
ngx.say("redis data = ",resp);
--正常情况理应有关闭redis，这里仅简单测试下，未做关闭
