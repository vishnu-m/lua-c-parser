local luaclang = require "luaclang"

--module table
local cparser = {}

local function enum_handler(cursor, declarations)
        local fields = {} 
        cursor:visitChildren(function (cursor, _)
                local kind = cursor:getKind()
                local enum_const
                if kind == "EnumConstantDecl" then
                        enum_const = {
                                name = cursor:getSpelling(),
                                value = cursor:getEnumValue()
                        }
                end
                table.insert(fields, enum_const)
                return "continue"
        end)
        local decl = {
                tag = 'enum',
                name = cursor:getSpelling(),
                fields = fields
        } 
        table.insert(declarations, decl)
end

local function union_struct_handler(cursor, declarations) 
        local fields = {}
        local definition = {}
        local decl = {
                name = cursor:getSpelling()
        }
        if cursor:getKind() == "StructDecl" then
                decl.tag = 'struct'
        else 
                decl.tag = 'union'
        end
        cursor:visitChildren(function (cursor, _)
                local kind = cursor:getKind()
                if kind == "FieldDecl" then
                        local type = cursor:getType()
                        local field = {
                                name = cursor:getSpelling(),
                                type = type:getSpelling(),
                        }
                        if cursor:isBitField() then
                                field.bit_field = "true"
                                field.field_width = cursor:getBitFieldWidth()
                        end
                        table.insert(fields, field)
                elseif kind == "StructDecl" or kind == "UnionDecl" then
                        union_struct_handler(cursor, definition)
                elseif kind == "EnumDecl" then
                        enum_handler(cursor, declarations)
                end
                return "continue"
        end) 
        decl.fields = fields
        if next(definition) ~= nil then
                decl.definition = definition
        end
        table.insert(declarations, decl)
end

local function var_handler(cursor, declarations)
        local type = cursor:getType()
        local decl = {
                tag = 'variable',
                name = cursor:getSpelling(),
                type = type:getSpelling(),
                storage_specifier = cursor:getStorageClass(),  
        }
        table.insert(declarations, decl)
end

local function function_handler(cursor, declarations)
        local func_params = {}
        local definition = {}
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
local function toplevel_visitor(cursor, _, declarations)
        local kind = cursor:getKind()
        if kind == "EnumDecl" then 
                enum_handler(cursor, declarations)
        elseif kind == "FunctionDecl" then
                function_handler(cursor, declarations)
        elseif kind == "TypedefDecl" then
                local underlying_type = cursor:getTypedefUnderlyingType()
                local type = cursor:getType()
                local decl = {
                        tag = 'typedef',
                        underlying_type = underlying_type:getSpelling(),
                        type = type:getSpelling()
                }
                table.insert(declarations, decl)
        elseif kind == "StructDecl" or kind == "UnionDecl" then
                union_struct_handler(cursor, declarations)
        elseif kind == "VarDecl" then
                var_handler(cursor, declarations)
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