local luaclang = require "luaclang"

--module table
local cparser = {}

function obtain_type(cursor_type)
        local type_kind = cursor_type:getTypeKind()
        if type_kind == "ConstantArray" then
                local element_type = cursor_type:getArrayElementType()
                return {
                        tag = 'array',
                        n = cursor_type:getArraySize(),
                        type = obtain_type(element_type)
                } 

        elseif type_kind == "Pointer" then
                local pointee_type = cursor_type:getPointeeType()
                if pointee_type:getTypeKind() ~= "FunctionProto" then
                        return {
                                tag = 'pointer',
                                type = obtain_type(pointee_type)
                        }
                else 
                        return obtain_type(pointee_type)
                end

        elseif type_kind == "FunctionProto" then
                local return_type = cursor_type:getResultType()
                local func_pointer_table = {
                        tag = 'function-pointer',
                        ret = obtain_type(return_type),
                        fields = {}
                }
                local num_params = cursor_type:getNumArgTypes() 
                for i=1, num_params do
                        local arg_type = cursor_type:getArgType(i)
                        table.insert(func_pointer_table.fields, obtain_type(arg_type))
                end
                return func_pointer_table            
        end
        return cursor_type:getSpelling()

end

local function enum_handler(cursor, declarations)
        local fields = {} 
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
        local decl = {
                tag = 'enum',
                name = cursor:getSpelling(),
                fields = fields
        } 
        table.insert(declarations, decl)
end

local function union_struct_handler(cursor, declarations) 
        local fields = {}
        cursor:visitChildren(function (cursor)
                local kind = cursor:getKind()
                if kind == "FieldDecl" then
                        local type = cursor:getType()
                        local field = {
                                name = cursor:getSpelling(),
                                type = obtain_type(type),
                        }
                        if cursor:isBitField() then
                                field.bit_field = "true"
                                field.field_width = cursor:getBitFieldWidth()
                        end
                        table.insert(fields, field)
                elseif kind == "StructDecl" or kind == "UnionDecl" then
                        union_struct_handler(cursor, declarations)
                elseif kind == "EnumDecl" then
                        enum_handler(cursor, declarations)
                end
                return "continue"
        end) 
        local decl = {
                name = cursor:getSpelling(),
                tag = cursor:getKind() == "StructDecl" and 'struct' or 'union',
                fields = fields
        }
        table.insert(declarations, decl)
end

local function var_handler(cursor, declarations)
        local type = cursor:getType()
        local decl = {
                tag = 'variable',
                name = cursor:getSpelling(),
                type = obtain_type(type),
                storage_specifier = cursor:getStorageClass(),  
        }
        table.insert(declarations, decl)
end

local function function_handler(cursor, declarations)
        local func_params = {}
        local type = cursor:getType()
        local return_type = type:getResultType()
        local num_params = cursor:getNumArgs()
        for i=1, num_params do
                local param_cursor = cursor:getArgCursor(i)
                param_type = param_cursor:getType()
                local param = {
                        name = param_cursor:getSpelling(),
                        type = obtain_type(param_type)
                }
                table.insert(func_params, param)
        end
        local decl = {
                tag = 'function',
                name = cursor:getSpelling(),
                inline = cursor:isFunctionInlined(),
                storage_specifier = cursor:getStorageClass(),
                ret = obtain_type(return_type),
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
                        underlying_type = obtain_type(underlying_type),
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