## 引子
日前，入手了本开涛写的《亿级流量网站架构核心技术》，里面提到nginx+lua相结合开发高并发、高负载下的服务，手痒就立个task，尝试一翻，随手把操作步骤列在下面，有兴趣的朋友也可以试试。

## 安装OpenResty
参考官方给出的yum安装步骤，各种系统均有支持，也可采用源码安装的形式，安装完成后默认路径是/usr/local/openresty
## 配置nginx
在http模块下面增加如下配置
>	lua_package_path "/usr/local/openresty/lualib/?.lua;;";  #lua 模块  
	lua_package_cpath "/usr/local/openresty/lualib/?.so;;";  #c模块 

为更好的配置lua配置，独立lua.conf文件，不与nginx.conf搅合一起，
lua.con文件中配置如下：
>#lua.conf  
server {  
    listen       80;  
    server_name  _;  
}  

在nginx.conf文件中http模块将其引入
>include lua.conf; 

## 测试配置结果
编写简单的lua脚本文件test.lua，存储目录位于conf/lua下面
>ngx.say("hello lua world");   

修改lua.conf
>location /lua {  
    default_type 'text/html';
    lua_code_cache off;
	content_by_lua_file conf/lua/test.lua;   
} 

测试配置是否正确
>./nginx -t  #检测配置文件是否正确 , 显示如下日志即表示成功

    nginx: [alert] lua_code_cache is off; this will hurt performance in /usr/local/nginx/conf/lua.conf:7
    nginx: [alert] lua_code_cache is off; this will hurt performance in /usr/local/nginx/conf/lua.conf:13
    nginx: the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
    nginx: configuration file /usr/local/nginx/conf/nginx.conf test is successful
在浏览器输入http://192.168.1.105/lua，页面正常输出“hello lua world ”

## 支持JSON
>脚本地址http://lua-users.org/wiki/JsonModules

正常的获取string类型值没有问题，在我们获取json格式的key值就需要JSON的支持才能正常显示。下载脚本dkjson.lua，将其放置在/usr/local/openresty/lualib目录下面，以便在lua脚本中引用

## 获取redis数据
编写连接redis的测试脚本，并从redis中获取指定key的值。脚本内容如下：
>local redis = require("resty.redis")  
local json = require ("dkjson")  
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
ngx.say("json data = ",json.encode(resp))

--正常情况理应有关闭redis，这里仅简单测试下，未做关闭

配置lua.conf，内容如下
>location /lua_redis_test {  
	default_type 'text/html';  
	lua_code_cache off;  
	content_by_lua_file /usr/local/nginx/conf/lua/json_test.lua;  
}

向redis中写入alibaba键的值，这里使用jedis简单写入即可
>Jedis redis = new Jedis("192.168.1.105", 6679);
		JSONObject object = new JSONObject();
		object.put("aaaa", 123);
		object.put("bbbbb", 23234);
		redis.set("alibaba", object.toString());

测试配置无误后，重启nginx。浏览器输入http://192.168.1.105/lua_redis_test，应当输出redis中alibaba键的值。
>redis data = {"aaaa":123,"bbbbb":23234}json data = "{\"aaaa\":123,\"bbbbb\":23234}

至此基于nginx，通过lua脚本即可简单从redis获取数据，大大提高的数据请求响应的效率。

## 扩展阅读
在github中发现有很多实用的lua插件，比如lua-resty-limit-traffic、lua-resty-jwt、lua-resty-kafka等等，有场景的时候确实可以考虑一下。

# 关注更多内容
![image](https://github.com/backkoms/simplemall/blob/develop/getqrcode.jpeg?raw=true)
