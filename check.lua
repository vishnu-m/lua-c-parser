local cparser = require "cparser"
local inspect = require "inspect"

declarations = cparser.parse("check.c")
print(inspect(declarations))
