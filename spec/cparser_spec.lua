local cparser = require "cparser"

describe("EnumDecl", function() 
        it("obtains the expected output", function()
                local expected = { {
                        fields = { {
                            name = "Red",
                            value = 0
                          }, {
                            name = "Black",
                            value = 1
                          }, {
                            name = "Yellow",
                            value = 2
                          } },
                        name = "colours",
                        tag = "enum"
                      }, {
                        fields = { {
                            name = "Mon",
                            value = 99
                          }, {
                            name = "Tue",
                            value = 100
                          }, {
                            name = "Wed",
                            value = 101
                          }, {
                            name = "Thur",
                            value = 102
                          }, {
                            name = "Fri",
                            value = 103
                          }, {
                            name = "Sat",
                            value = 104
                          }, {
                            name = "Sun",
                            value = 105
                          } },
                        name = "week",
                        tag = "enum"
                      }, {
                        fields = { {
                            name = "item1",
                            value = 0
                          }, {
                            name = "item2",
                            value = 1
                          } },
                        name = "",
                        tag = "enum"
                      } }
                    
                local declarations = cparser.parse("spec/enum.h")
                assert.are.same(expected, declarations)
        end)
end)

describe("FunctionDecl", function() 
        it("obtains the expected output", function()
                local expected = { {
                        inline = false,
                        name = "max",
                        params = { {
                            name = "a",
                            type = "int"
                          }, {
                            name = "b",
                            type = "int"
                          } },
                        ret = "int",
                        storage_specifier = "extern",
                        tag = "function"
                      }, {
                        inline = false,
                        name = "foo",
                        params = { {
                            name = "p",
                            type = "const void *"
                          } },
                        ret = "int (*)[3]",
                        storage_specifier = "none",
                        tag = "function"
                      }, {
                        inline = false,
                        name = "check",
                        params = {},
                        ret = "const double",
                        storage_specifier = "static",
                        tag = "function"
                      }, {
                        inline = true,
                        name = "sum",
                        params = { {
                            name = "a",
                            type = "int"
                          }, {
                            name = "b",
                            type = "int"
                          } },
                        ret = "int",
                        storage_specifier = "none",
                        tag = "function"
                      }, {
                        inline = false,
                        name = "increment",
                        params = { {
                            name = "a",
                            type = "int"
                          } },
                        ret = "int",
                        storage_specifier = "none",
                        tag = "function"
                      } }
                    
                local declarations = cparser.parse("spec/function.h")
                assert.are.same(expected, declarations)
        end)
end)

describe("TypedefDecl", function()
        it("obtains the expected output", function()
                local expected = { {
                        tag = "typedef",
                        type = "DRAWF",
                        underlying_type = "void (int, int)"
                      }, {
                        tag = "typedef",
                        type = "char_t",
                        underlying_type = "char"
                      }, {
                        tag = "typedef",
                        type = "char_p",
                        underlying_type = "char *"
                      }, {
                        tag = "typedef",
                        type = "fp",
                        underlying_type = "char (*)(void)"
                      } }
                
                local declarations = cparser.parse("spec/typedef.h")
                assert.are.same(expected, declarations)
        end)
end)