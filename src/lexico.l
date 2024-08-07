%{
#include <string>
%}

SPACE [ \t]
DIGIT [0-9]
LETTER [A-Za-z]
UNDERSCORE _

NUMBER ({DIGIT})+
REAL [-]?(((({DIGIT}+)|({DIGIT}*\.{DIGIT}+))([eE][-+]?{DIGIT}+)?))

OTHER_BASE_INTEGER [-]?0{LETTER}({DIGIT}|{LETTER})+
DECIMAL_INTEGER [-]?{NUMBER}

CHAR \'({LETTER}|{DIGIT})\'
STRING \"(\\.|[^"\\])*\"
ID ({LETTER}|{UNDERSCORE})({LETTER}|{DIGIT}|{UNDERSCORE})*

TYPES "number"|"bool"|"char"|"string"|"void"

%option stack
%s SC_PROGRAM
%x SC_STRING

%%

{SPACE}+             { /* ignore whitespace */                                       }
"\n"                 { addLine();                                                    }
       
"assertEquals"       { return TK_ASSERT_EQUALS;                                      }
"println"            { return TK_PRINTLN;                                            }
"print"              { return TK_PRINT;                                              }
"scan"               { return TK_SCAN;                                               }
"typeof"             { return TK_TYPEOF;                                             }
"length"             { return TK_LENGTH;                                             }
       
"do"                 { return TK_DO;                                                 }
"while"              { return TK_WHILE;                                              }
"for"                { return TK_FOR;                                                }
"in"                 { return TK_IN;                                                 }

"break"              { return TK_BREAK;                                              }
"continue"           { return TK_CONTINUE;                                           }
"switch"             { return TK_SWITCH;                                             }
"->"                 { return TK_ARROW;                                              }

"if"                 { return TK_IF;                                                 }
"else"               { return TK_ELSE;                                               }
       
"return"             { return TK_RETURN;                                             }
"fn"                 { return TK_FUNCTION;                                           }
"let"                { return TK_LET;                                                }
"const"              { return TK_CONST;                                              }
            
"true"               { yylval.label = "true"; return TK_BOOLEAN;                     }
"false"              { yylval.label = "false"; return TK_BOOLEAN;                    }

"like"               { return TK_LIKE;                                               }

"and"                { return TK_AND;                                                }
"or"                 { return TK_OR;                                                 }
"!"|"not"            { return TK_NOT;                                                }
       
"&"                  { return TK_BITAND;                                             }
"|"                  { return TK_BITOR;                                              }
"~"                  { return TK_BITNOT;                                             }
"^"                  { return TK_BITXOR;                                             }
"<<"                 { return TK_BITLEFT;                                            }
">>"                 { return TK_BITRIGHT;                                           }

"+="                 { return TK_PLUS_EQUALS;                                        }
"-="                 { return TK_MINUS_EQUALS;                                       }
"=="                 { return TK_EQUALS;                                             }
"!="                 { return TK_DIFFERENT;                                          }
">="                 { return TK_GREATER_EQUALS;                                     }
"<="                 { return TK_LESS_EQUALS;                                        }
">"                  { return TK_GREATER;                                            }
"<"                  { return TK_LESS;                                               }
       
"."                  { return '.';                                                   }
       
[`]                  { yy_push_state(SC_STRING);    return '`';                      }
<SC_STRING>[`]       { yy_pop_state();              return '`';                      }
<*>"${"              { yy_push_state(SC_PROGRAM);   return TK_INTER_START;           }
<INITIAL>"}$"        { return TK_INTER_END;                                          }
<*>"}$"              { yy_pop_state();              return TK_INTER_END;             } 

<SC_STRING>{ 
  [^\\]              { yylval.label = strdup(yytext);        return TK_INTER_STRING; }
 
  \\.                { yylval.label = strdup(yytext);        return TK_INTER_STRING; }
}

"<>"                 { return TK_CONCAT;                                             }
"//"                 { return TK_DIV;                                                }
"**"                 { return TK_POW;                                                }
[+\-*/|\"]           { return *yytext;                                               }
[(){}[\]]            { return *yytext;                                               }
[;,~:=%_]            { return *yytext;                                               }

"int"                { yylval.label = "int"; return TK_INT;                          }
"float"              { yylval.label = "float"; return TK_FLOAT;                      }

"array<str>"         { yylval.label = "StringArray"; return TK_TYPE;                 }
"array<string>"      { yylval.label = "StringArray"; return TK_TYPE;                 }
"array<number>"      { yylval.label = "NumberArray"; return TK_TYPE;                 }
"array<bool>"        { yylval.label = "BoolArray"; return TK_TYPE;                   }
"array<char>"        { yylval.label = "CharArray"; return TK_TYPE;                   }
"str"                { yylval.label = "string"; return TK_TYPE;                      }
{TYPES}              { yylval.label = yytext; return TK_TYPE;                        } 

{STRING}             { yylval.label = yytext; return TK_STRING;                      }
{CHAR}		           { yylval.label = yytext; return TK_CHAR;                        }
        
{OTHER_BASE_INTEGER} { yylval.label = yytext; return TK_INTEGER_BASE;                }
{DECIMAL_INTEGER}    { yylval.label = yytext; return TK_INTEGER;                     }
        
{REAL}	             { yylval.label = yytext; return TK_REAL;                        }
{ID}		             { yylval.label = yytext; return TK_ID;                          }   
      
.                    { *yytext;                                                      }

%%