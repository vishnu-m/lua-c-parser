local cparser = require "cparser"
local inspect = require "inspect"

declarations = cparser.parse("check.h")
print(inspect(declarations))
