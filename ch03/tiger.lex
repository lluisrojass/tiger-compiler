%{
#include <string.h>
#include "util.h"
#include "tokens.h"
#include "errormsg.h"

int charPos=1;

extern YYSTYPE yylval;

/* force end of scanning after one file */
int yywrap(void) {
 charPos=1;
 return 1;
}

// var to keep track of interior comments
int comment_count = 0;

void adjust(void) {
  EM_tokPos=charPos;
  charPos+=yyleng;
}

// sb vars
char *buffer;
int max_str_length = 32;

// initializes buffer & resets string size variable
void init_str(void){
  buffer = malloc(sizeof(char) * max_str_length);
  max_str_length = 32;
}

// adds char to string
void add_char(char c){
  size_t len = strlen(buffer)+1;
  if (len == max_str_length){
    max_str_length *= 2;
    char *tmp = malloc(sizeof(char) * max_str_length);
    memcpy(tmp, buffer, len);
    free(buffer);
    buffer = tmp;
  }
  buffer[len - 1] = c;
  buffer[len] = 0;
}

%}
%x STRING COMMENT
%%

var       { adjust(); return VAR;     }
type      { adjust(); return TYPE;    }
function  { adjust(); return FUNCTION;}
nil       { adjust(); return NIL;     }
break     { adjust(); return BREAK;   }
of        { adjust(); return OF;      }
let       { adjust(); return LET;     }
in        { adjust(); return IN;      }
end       { adjust(); return END;     }
do        { adjust(); return DO;      }
for       { adjust(); return FOR;     }
to        { adjust(); return TO;      }
while     { adjust(); return WHILE;   }
else      { adjust(); return ELSE;    }
if        { adjust(); return IF;      }
then      { adjust(); return THEN;    }
array     { adjust(); return ARRAY;   }


\n	   { adjust(); EM_newline();  }
":="   { adjust(); return ASSIGN; }
"|"    { adjust(); return OR;     }
"/*"   { adjust(); BEGIN COMMENT; comment_count+=1; }
"&"    { adjust(); return AND;    }
">="   { adjust(); return GE;     }
">"    { adjust(); return GT;     }
"<="   { adjust(); return LE;     }
"<"    { adjust(); return LT;     }
"<>"   { adjust(); return NEQ;    }
"="    { adjust(); return EQ;     }
"/"    { adjust(); return DIVIDE; }
"*"    { adjust(); return TIMES;  }
"-"    { adjust(); return MINUS;  }
"+"    { adjust(); return PLUS;   }
"."    { adjust(); return DOT;    }
"["    { adjust(); return LBRACK; }
"]"    { adjust(); return RBRACK; }
"}"    { adjust(); return RBRACE; }
"{"    { adjust(); return LBRACE; }
")"    { adjust(); return RPAREN; }
"("    { adjust(); return LPAREN; }
";"    { adjust(); return SEMICOLON; }
":"    { adjust(); return COLON;  }
" "	   { adjust(); continue;      }
","	   { adjust(); return COMMA;  }

[0-9]+ {
  adjust();
  yylval.ival=atoi(yytext);
  return INT;
}


\" {
  adjust();
  init_str();
  BEGIN STRING;
}

[a-zA-Z][_a-zA-Z0-9]* {
  adjust();
  yylval.sval=yytext;
  return ID;
}

. {
  adjust();
  EM_error(EM_tokPos, "illegal token");
  yyterminate();
}

<COMMENT>{
   "/*" {
      adjust();
      comment_count += 1;
   }
   \n {
        adjust();
        EM_newline();
   }
   "*/" {
      adjust();
      comment_count -= 1;
      if (comment_count == 0) BEGIN INITIAL;
   }
   <<EOF>> {
      adjust();
      EM_error(EM_tokPos, "File ended inside comment");
      yyterminate();
   }
   . {
      adjust();
   }
}

<STRING>{
  \\[ \t\n\f]+\\ {
      adjust();
      int j;
      for(j = 0; j < yyleng ; j++){
        if (yytext[j] == '\n'){
          EM_newline();
        }
      }
  }

  \\t {
    adjust();
    add_char('\t');
  }

  \\n {
    adjust();
    add_char('\n');
  }

  \" {
    adjust();
    BEGIN INITIAL;
    yylval.sval = strdup(buffer);
    free(buffer);
    return STR;
  }

  \\[0-9]+ {
    adjust();
    int d;
    sscanf(yytext+1,"%d",&d);
    if (d > 127){
      EM_error(EM_tokPos, "Invalid ASCII sequence \"\\%d\" ", d);
      yyterminate();
    }
    add_char(d);
  }

  \\\" {
    adjust();
    add_char('\"');
  }

  \\\^[A-Z@\[\]\\\^_\?] {
      adjust();
      add_char(yytext[2]-64);
  }
  . {
    adjust();
    add_char(*yytext);
  }
}
