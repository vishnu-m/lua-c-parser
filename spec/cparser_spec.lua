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
                      }, {
                        fields = { {
                            name = "A",
                            value = 0
                          }, {
                            name = "B",
                            value = 1
                          }, {
                            name = "C",
                            value = 10
                          }, {
                            name = "D",
                            value = 11
                          }, {
                            name = "E",
                            value = 1
                          }, {
                            name = "F",
                            value = 2
                          }, {
                            name = "G",
                            value = 12
                          } },
                        name = "Foo",
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
                }, {
                  fields = { {
                      name = "a",
                      type = "int"
                    } },
                  name = "",
                  tag = "struct"
                }, {
                  inline = false,
                  name = "foo",
                  params = {},
                  ret = "struct (anonymous struct at spec/function.h:23:1)",
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
                        fields = { {
                            name = "name",
                            type = "char [30]"
                          }, {
                            name = "size",
                            type = "int"
                          }, {
                            name = "year",
                            type = "int"
                          } },
                        name = "club",
                        tag = "struct"
                      }, {
                        tag = "typedef",
                        type = "GROUP",
                        underlying_type = "struct club"
                      }, {
                        tag = "typedef",
                        type = "PG",
                        underlying_type = "GROUP *"
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

describe("StrucDecl", function()
        it("obtains the expected output", function()
                local expected = { {
                        fields = { {
                            name = "x",
                            type = "int"
                          }, {
                            name = "y",
                            type = "int"
                          } },
                        name = "coordinates",
                        tag = "struct"
                      }, {
                        fields = { {
                            name = "Violet",
                            value = 0
                          }, {
                            name = "Indigo",
                            value = 1
                          }, {
                            name = "Blue",
                            value = 2
                          }, {
                            name = "Green",
                            value = 3
                          }, {
                            name = "Yellow",
                            value = 4
                          }, {
                            name = "Red",
                            value = 5
                          } },
                        name = "Fruit",
                        tag = "enum"
                      }, {
                        fields = { {
                            name = "field1",
                            type = "enum Fruit"
                          } },
                        name = "rainbow",
                        tag = "struct"
                      }, {
                        fields = { {
                            name = "alpha",
                            type = "char"
                          }, {
                            name = "num",
                            type = "int"
                          } },
                        name = "",
                        tag = "struct"
                      }, {
                        name = "var",
                        storage_specifier = "none",
                        tag = "variable",
                        type = "struct (anonymous struct at spec/struct.h:13:1)"
                      }, {
                        fields = { {
                            name = "physics",
                            type = "int"
                          } },
                        name = "marks",
                        tag = "struct"
                      }, {
                        fields = { {
                            name = "m1",
                            type = "struct marks"
                          }, {
                            name = "m2",
                            type = "struct marks"
                          }, {
                            name = "pointer",
                            type = "struct Student *"
                          }, {
                            name = "double_pointer",
                            type = "struct Student **"
                          } },
                        name = "Student",
                        tag = "struct"
                      }, {
                        fields = { {
                            name = "f",
                            type = "int (*)(int)"
                          } },
                        name = "mycallback",
                        tag = "struct"
                      }, {
                        fields = { {
                            bit_field = "true",
                            field_width = 5,
                            name = "x",
                            type = "int"
                          }, {
                            bit_field = "true",
                            field_width = 1,
                            name = "y",
                            type = "int"
                          }, {
                            bit_field = "true",
                            field_width = 2,
                            name = "z",
                            type = "int"
                          } },
                        name = "bits",
                        tag = "struct"
                      }, {
                        fields = {},
                        name = "context",
                        tag = "struct"
                      }, {
                        fields = { {
                            name = "ctx",
                            type = "struct context *"
                          } },
                        name = "funcptrs",
                        tag = "struct"
                      }, {
                        fields = { {
                            name = "fps",
                            type = "struct funcptrs"
                          } },
                        name = "context",
                        tag = "struct"
                      }, {
                        fields = { {
                            name = "a",
                            type = "int"
                          } },
                        name = "",
                        tag = "struct"
                      }, {
                        fields = { {
                            name = "svar1",
                            type = "struct (anonymous struct at spec/struct.h:54:17)"
                          } },
                        name = "u1",
                        tag = "union"
                      }, {
                        fields = { {
                            name = "b",
                            type = "float"
                          }, {
                            name = "uvar1",
                            type = "union u1"
                          } },
                        name = "st1",
                        tag = "struct"
                      }, {
                        fields = { {
                            name = "a",
                            type = "int"
                          } },
                        name = "",
                        tag = "union"
                      }, {
                        fields = { {
                            name = "u",
                            type = "union (anonymous union at spec/struct.h:62:2)"
                          }, {
                            name = "b",
                            type = "int"
                          } },
                        name = "st2",
                        tag = "struct"
                      } }
                
                local declarations = cparser.parse("spec/struct.h")
                assert.are.same(expected, declarations)
        end)
end)

describe("UnionDecl", function()
        it("obtains the expected output", function()
                local expected = { {
                        fields = { {
                            name = "x",
                            type = "const int"
                          }, {
                            name = "y",
                            type = "const int"
                          } },
                        name = "check",
                        tag = "union"
                      }, {
                        fields = { {
                            name = "a",
                            type = "const int"
                          } },
                        name = "",
                        tag = "union"
                      }, {
                        name = "u1",
                        storage_specifier = "none",
                        tag = "variable",
                        type = "union (anonymous union at spec/union.h:7:1)"
                      }, {
                        fields = { {
                            name = "b",
                            type = "double"
                          } },
                        name = "st1",
                        tag = "struct"
                      }, {
                        fields = { {
                            name = "s",
                            type = "char *"
                          } },
                        name = "un2",
                        tag = "union"
                      }, {
                        fields = { {
                            bit_field = "true",
                            field_width = 8,
                            name = "icon",
                            type = "unsigned int"
                          }, {
                            bit_field = "true",
                            field_width = 4,
                            name = "color",
                            type = "unsigned int"
                          } },
                        name = "",
                        tag = "struct"
                      }, {
                        fields = { {
                            name = "window1",
                            type = "struct (anonymous struct at spec/union.h:22:9)"
                          }, {
                            name = "screenval",
                            type = "int"
                          } },
                        name = "",
                        tag = "union"
                      }, {
                        name = "screen",
                        storage_specifier = "none",
                        tag = "variable",
                        type = "union (anonymous union at spec/union.h:21:1) [25][80]"
                      } }

                local declarations = cparser.parse("spec/union.h")
                assert.are.same(expected, declarations)
        end)
end)

describe("VarDecl", function()
        it("obtains the expected output", function()
                local expected = { {
                        name = "list",
                        storage_specifier = "static",
                        tag = "variable",
                        type = "int [20]"
                      }, {
                        name = "aptr",
                        storage_specifier = "none",
                        tag = "variable",
                        type = "int *[10]"
                      }, {
                        fields = { {
                            name = "a",
                            type = "int"
                          } },
                        name = "st1",
                        tag = "struct"
                      }, {
                        name = "st1_instance",
                        storage_specifier = "none",
                        tag = "variable",
                        type = "struct st1"
                      }, {
                        fields = { {
                            name = "s",
                            type = "char *"
                          } },
                        name = "un1",
                        tag = "union"
                      }, {
                        name = "un1_instance",
                        storage_specifier = "none",
                        tag = "variable",
                        type = "union un1"
                      } }
                
                local declarations = cparser.parse("spec/variable.h")
                assert.are.same(expected, declarations)
        end)
end)