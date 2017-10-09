local function close_db(db)
    if not db then
        return
    end
    db:close()
end

local mysql = require("resty.mysql")

local json = require("dkjson")

local db, err = mysql:new()
if not db then
    ngx.say("error : ", err)
    return
end

db:set_timeout(1000)

local props = {
    host = "192.168.1.104",
    port = 3306,
    database = "sonar",
    user = "root",
    password = "root"
}

local res, err, errno, sqlstate = db:connect(props)

if not res then
   ngx.say("connect error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
   return close_db(db)
end

local select_sql = "select * from dashboards"
res, err, errno, sqlstate = db:query(select_sql)
if not res then
   ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
   return close_db(db)
end

for i, row in ipairs(res) do  
   for name, value in pairs(row) do  
     ngx.say("select row =", i, " : ", name, " = ", value, "<br/>")  
   end  
end  



close_db(db)

