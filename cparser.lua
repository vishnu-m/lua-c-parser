local lib = require "luaclang"

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

--global visitor for spotting all declarations in the file
local function toplevel_visitor(cursor, parent, declarations)
        local kind = cursor:getKind()
        if kind == "EnumDecl" then 
                enum_handler(cursor, parent, declarations)
        end
        return "continue"
end 

function cparser.parse(file_name)
        parser = lib.newParser(file_name)
        cur = parser:getCursor()
        cur:visitChildren(toplevel_visitor, declarations)
        parser:dispose()
        return declarations
end

return cparser  