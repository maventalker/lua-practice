local template = require("resty.template") 

local context = {who = "Bratish",from="usgrouping"}  

template.render("template2.html", context) 