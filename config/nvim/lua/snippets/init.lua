-- Custom snippets
local luasnip = require('luasnip')
local s = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node
local f = luasnip.function_node

-- Add your custom snippets here
luasnip.add_snippets("python", {
  s("Person", {
    t("class Person:"),
    t({"", "    def __init__(self, "}),
    i(1, "name"),                    -- 第1个占位符：参数名1
    t(", "),
    i(2, "age"),                     -- 第2个占位符：参数名2  
    t("):"),
    t({"", "        self."}),
    f(function(args) return args[1][1] end, {1}),  -- 自动复制第1个参数
    t(" = "),
    f(function(args) return args[1][1] end, {1}),  -- 再次复制第1个参数
    t({"", "        self."}),
    f(function(args) return args[1][1] end, {2}),  -- 自动复制第2个参数
    t(" = "),
    f(function(args) return args[1][1] end, {2}),  -- 再次复制第2个参数
    i(0)                             -- 最后的光标位置
  }),
  -- 带类型注解的版本
  s("PersonTyped", {
    t("class Person:"),
    t({"", "    def __init__(self, "}),
    i(1, "name"),
    t(": "),
    i(2, "str"),
    t(", "),
    i(3, "age"),
    t(": "),
    i(4, "int"),
    t("):"),
    t({"", "        self."}),
    f(function(args) return args[1][1] end, {1}),  -- 复制 name
    t(" = "),
    f(function(args) return args[1][1] end, {1}),  -- 复制 name
    t({"", "        self."}),
    f(function(args) return args[1][1] end, {3}),  -- 复制 age
    t(" = "),
    f(function(args) return args[1][1] end, {3}),  -- 复制 age
    i(0)
  }),
  s("PersonM", {
    t("class MetaPerson(type):"),
    t({"", "    registry = {}"}),
    t({"", "    def __new__(cls, name, bases, attrs):"}),
    t({"", "        meta_cls = super().__new__(cls, name, bases, attrs)"}),
    t({"", "        if \""}), i(1, "species_code"), t("\" in attrs:"),
    t({"", "            cls.registry[attrs[\""}), f(function(args) return args[1][1] end, {1}), t("\"]] = meta_cls"),
    t({"", "        return meta_cls"}),
    i(0)
  }),
  s("Vali", {
    t("class ValidateField:"),
    t({"", "    def __init__(self, attr_name, "}), i(1, "validator"), t("):"),
    t({"", "        self.attr_name = \"_\" + attr_name"}),
    t({"", "        self."}), f(function(args) return args[1][1] end, {1}),  -- 这里用输入直接替代self.xxx
    t(" = "), f(function(args) return args[1][1] end, {1}),  -- 赋值也是输入
    t({"", "", "    def __set__(self, instance, value):"}),
    t({"", "        "}), f(function(args) return "self." .. args[1][1] .. "(value)" end, {1}),
    t({"", "        setattr(instance, self.attr_name, value)"}),
    t({"", "", "    def __get__(self, instance, owner):"}),
    t({"", "        return getattr(instance, self.attr_name)"}),
    i(0)
  })
})

