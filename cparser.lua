local luaclang = require "luaclang"

--module table
local cparser = {}

function obtain_type(cursor_type, cursor_map)
        local type_kind = cursor_type:getTypeKind()
        if type_kind == "ConstantArray" then
                local element_type = cursor_type:getArrayElementType()
                return {
                        tag = 'array',
                        n = cursor_type:getArraySize(),
                        type = obtain_type(element_type, cursor_map)
                } 

        elseif type_kind == "Pointer" then
                local pointee_type = cursor_type:getPointeeType()
                if pointee_type:getTypeKind() ~= "FunctionProto" then
                        return {
                                tag = 'pointer',
                                type = obtain_type(pointee_type, cursor_map)
                        }
                else 
                        return obtain_type(pointee_type, cursor_map)
                end

        elseif type_kind == "FunctionProto" then
                local return_type = cursor_type:getResultType()
                local func_pointer_table = {
                        tag = 'function-pointer',
                        ret = obtain_type(return_type, cursor_map),
                        fields = {}
                }
                local num_params = cursor_type:getNumArgTypes() 
                for i=1, num_params do
                        local arg_type = cursor_type:getArgType(i)
                        table.insert(func_pointer_table.fields, obtain_type(arg_type, cursor_map))
                end
                return func_pointer_table            

        elseif type_kind == "Elaborated" or type_kind == "Typedef" then
                local cursor = cursor_type:getTypeDeclaration()
                        for i, c in ipairs(cursor_map) do
                                if c:equals(cursor) then
                                        return {
                                                tag = 'decl',
                                                decl = i
                                        }
                                end
                        end
        end
        return cursor_type:getSpelling()
end

function add_declaration(cursor, decl, declarations, cursor_map)
        table.insert(declarations, decl)
        table.insert(cursor_map, cursor)
end

local function enum_handler(cursor, declarations, cursor_map)
        local fields = {} 
        local decl = {
                tag = 'enum',
                name = cursor:getSpelling(),
                fields = fields
        } 
        add_declaration(cursor, decl, declarations, cursor_map)
        cursor:visitChildren(function (cursor)
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
end

local function union_struct_handler(cursor, declarations, cursor_map) 
        local fields = {}
        local decl = {
                name = cursor:getSpelling(),
                tag = cursor:getKind() == "StructDecl" and 'struct' or 'union',
                fields = fields
        }
        add_declaration(cursor, decl, declarations, cursor_map)
        cursor:visitChildren(function (cursor)
                local kind = cursor:getKind()
                if kind == "FieldDecl" then
                        local type = cursor:getType()
                        local field = {
                                name = cursor:getSpelling(),
                                type = obtain_type(type, cursor_map),
                        }
                        if cursor:isBitField() then
                                field.bit_field = "true"
                                field.field_width = cursor:getBitFieldWidth()
                        end
                        table.insert(fields, field)
                elseif kind == "StructDecl" or kind == "UnionDecl" then
                        union_struct_handler(cursor, declarations, cursor_map)
                elseif kind == "EnumDecl" then
                        enum_handler(cursor, declarations, cursor_map)
                end

                return "continue"
        end) 
end

local function var_handler(cursor, declarations, cursor_map)
        table.insert(cursor_map, cursor)
        local type = cursor:getType()
        local decl = {
                tag = 'variable',
                name = cursor:getSpelling(),
                type = obtain_type(type, cursor_map),
                storage_specifier = cursor:getStorageClass(),  
        }
        table.insert(declarations, decl)
end

local function function_handler(cursor, declarations, cursor_map)
        local func_params = {}
        local type = cursor:getType()
        local return_type = type:getResultType()
        local decl = {
                tag = 'function',
                name = cursor:getSpelling(),
                inline = cursor:isFunctionInlined(),
                storage_specifier = cursor:getStorageClass(),
                ret = obtain_type(return_type, cursor_map),
                params = func_params
        }
        add_declaration(cursor, decl, declarations, cursor_map)
        local num_params = cursor:getNumArgs()
        for i=1, num_params do
                local param_cursor = cursor:getArgCursor(i)
                param_type = param_cursor:getType()
                local param = {
                        name = param_cursor:getSpelling(),
                        type = obtain_type(param_type, cursor_map)
                }
                table.insert(func_params, param)
        end
end

--global visitor for spotting all declarations in the file
local function toplevel_visitor(cursor, _, declarations, cursor_map)
        local kind = cursor:getKind()
        if kind == "EnumDecl" then 
                enum_handler(cursor, declarations, cursor_map)
        elseif kind == "FunctionDecl" then
                function_handler(cursor, declarations, cursor_map)
        elseif kind == "TypedefDecl" then
                local underlying_type = cursor:getTypedefUnderlyingType()
                local type = cursor:getType()
                local decl = {
                        tag = 'typedef',
                        underlying_type = obtain_type(underlying_type, cursor_map),
                        type = type:getSpelling()
                }
                add_declaration(cursor, decl, declarations, cursor_map)
        elseif kind == "StructDecl" or kind == "UnionDecl" then
                union_struct_handler(cursor, declarations, cursor_map)
        elseif kind == "VarDecl" then
                var_handler(cursor, declarations, cursor_map)
        end
        return "continue"
end 

function cparser.parse(file_name)
        local parser = luaclang.newParser(file_name)
        local declarations = {}
        local cursor_map = {}           --auxiliary table for referencing cursors 
        local cur = parser:getCursor()
        cur:visitChildren(toplevel_visitor, declarations, cursor_map)
        parser:dispose()
        return declarations
end

return cparser  