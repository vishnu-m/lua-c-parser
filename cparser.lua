local luaclang = require "luaclang"

--module table
local cparser = {}

local function enum_handler(cursor, parent, declarations)
        local fields = {} 
        cursor:visitChildren(function (cursor, parent, fields)
                local kind = cursor:getKind()
                local enum_const
                if kind == "EnumConstantDecl" then
                        enum_const = {}
                        enum_const.name = cursor:getSpelling()
                        enum_const.value = cursor:getEnumValue()
                end
                table.insert(fields, enum_const)
                return "continue"
        end, fields)
        local decl = {
                tag = 'enum',
                name = cursor:getSpelling(),
                fields = fields
        } 
        table.insert(declarations, decl)
end

local function function_handler(cursor, parent, declarations)
        local func_params = {}
        local type = cursor:getType()
        local return_type = type:getResultType()
        local num_params = cursor:getNumArgs()
        for i=1, num_params do
                local param_cursor = cursor:getArgCursor(i)
                param_type = param_cursor:getType()
                local param = {
                        name = param_cursor:getSpelling(),
                        type = param_type:getSpelling()
                }
                table.insert(func_params, param)
        end
        local decl = {
                tag = 'function',
                name = cursor:getSpelling(),
                inline = cursor:isFunctionInlined(),
                storage_specifier = cursor:getStorageClass(),
                ret = return_type:getSpelling(),
                params = func_params
        }
        table.insert(declarations, decl)
end

--global visitor for spotting all declarations in the file
local function toplevel_visitor(cursor, parent, declarations)
        local kind = cursor:getKind()
        if kind == "EnumDecl" then 
                enum_handler(cursor, parent, declarations)
        elseif kind == "FunctionDecl" then
                function_handler(cursor, parent, declarations)
        end
        return "continue"
end 

function cparser.parse(file_name)
        local parser = luaclang.newParser(file_name)
        local declarations = {}
        local cur = parser:getCursor()
        cur:visitChildren(toplevel_visitor, declarations)
        parser:dispose()
        return declarations
end

return cparser  