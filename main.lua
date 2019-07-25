local lib = require "luaclang"
local inspect = require "inspect"

--table containing all declarations in the file
local declarations = {}

local enum_child_visitor

local enum_decl 
local enum_fields  

local function enum_handler(cursor, parent)
        --table containing contents of a single EnumDecl
        enum_decl = {} 

        --table containing fields(EnumConstantDecls) for an EnumDecl
        enum_fields = {} 

        enum_decl.tag = 'enum'
        enum_decl.name = cursor:getSpelling()

        --visit children of an EnumDecl
        cursor:visitChildren(enum_child_visitor)
        enum_decl.fields = enum_fields

        --Add declaration to declarations table
        declarations[#declarations+1] = enum_decl
end

--visitor function for traversing children of an EnumDecl
enum_child_visitor = function (cursor, parent)
        local kind = cursor:getKind()
        local enum_const
        if kind == "EnumConstantDecl" then
                enum_const = {}
                enum_const.name = cursor:getSpelling()

        elseif kind == "IntegerLiteral" then
                enum_fields[#enum_fields].value = parent:getEnumValue()
        end
        enum_fields[#enum_fields+1] = enum_const
        return "recurse"

end

--global visitor for spotting all declarations in the file
local function toplevel_visitor(cursor, parent)
        kind = cursor:getKind();
        if kind == "EnumDecl" then 
                enum_handler(cursor, parent)
        end
        return "continue"
end 

--create the parser object
parser = lib.newParser("check.c")
cur = parser:getCursor()

--main visit children call 
cur:visitChildren(toplevel_visitor)

--pretty-print the table
print(inspect(declarations))

--dispose the parser object
parser:dispose()