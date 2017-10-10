--测试template组件，填充一些变量数据
local template = require("resty.template") 
local redis = require("resty.redis")

local redis_instance = redis:new()
redis_instance:set_timeout(3000)

local host = "127.0.0.1"
local port = 6679
local ok, err = redis_instance:connect(host, port)
if not ok then
ngx.say("connect to redis error : ", err)
return close_redis(redis_instance)
end
local resp, err = redis_instance:eval("return redis.call('get', KEYS[1])", 1, "alibaba");

local context = {who = "Bratish",from="usgrouping",jsons= {aaaa=123,bbbbb=23234}}  

template.render("template3.html", context,resp) 