--测试template组件，填充一些变量数据
local template = require("resty.template") 

local context = {who = "Bratish",from="usgrouping"}  

template.render("template2.html", context) 