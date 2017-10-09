local http = require("resty.http")  

local httpc = http.new()  

--如果出现 no resolver defined to resolve so.csdn.net，需要在nginx下的server模块中添加 resolver 192.168.1.1 s.taobao.com so.csdn.net;

local resp, err = httpc:request_uri("http://so.csdn.net/so", {  
    method = "GET",  
    path = "/search/s.do?q=jwt",  
    headers = {  
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.111 Safari/537.36"  
    }  
})  
  
if not resp then  
    ngx.say("request error :", err)  
    return  
end  
  

ngx.status = resp.status  
  

for k, v in pairs(resp.headers) do  
    if k ~= "Transfer-Encoding" and k ~= "Connection" then  
        ngx.header[k] = v  
    end  
end  
 
ngx.say(resp.body)  
  
httpc:close() 
