local lib = require "luaclang"

--module table
local cparser = {}

local declarations = {}

--visitor function for traversing children of an EnumDecl
local function enum_child_visitor(cursor, parent, enum_fields)
        local kind = cursor:getKind()
        local enum_const
        if kind == "EnumConstantDecl" then
                enum_const = {}
                enum_const.name = cursor:getSpelling()
        elseif kind == "IntegerLiteral" then
                enum_fields[#enum_fields].value = parent:getEnumValue()
        end
        table.insert(enum_fields, enum_const)
        return "recurse"
end

local function enum_handler(cursor, parent, declarations)
        local enum_decl = {} 
        local enum_fields = {} 
        enum_decl.tag = 'enum'
        enum_decl.name = cursor:getSpelling()
        cursor:visitChildren(enum_child_visitor, enum_fields)
        enum_decl.fields = enum_fields
        table.insert(declarations, enum_decl)
end

local function function_handler(cursor, parent, declarations)
        local func_decl = {}
        local func_params = {}
        func_decl.tag = 'function'
        func_decl.name = cursor:getSpelling()
        func_decl.inline = cursor:isFunctionInlined()
        func_decl.storage_specifier = cursor:getStorageClass()
        local type = cursor:getType()
        local return_type = type:getResultType()
        func_decl["return"] = return_type:getSpelling()
        local num_params = cursor:getNumArgs()
        local param
        for i=0, num_params-1 do
                param = {}
                local param_cursor = cursor:getArgCursor(i)
                param.name = param_cursor:getSpelling()
                param_type = param_cursor:getType()
                param.type = param_type:getSpelling()
                table.insert(func_params, param)
        end
        func_decl.params = func_params
        table.insert(declarations, func_decl)
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
        local parser = lib.newParser(file_name)
        local cur = parser:getCursor()
        cur:visitChildren(toplevel_visitor, declarations)
        parser:dispose()
        return declarations
end

return cparser  