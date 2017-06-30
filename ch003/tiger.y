%{
#include <stdio.h>
#include "util.h"
#include "errormsg.h"

int yylex(void); /* function prototype */

void yyerror(char *s)
{
 EM_error(EM_tokPos, "%s", s);
}
%}


%union {
	int pos;
	int ival;
	string sval;
}

%token <sval> ID STRING
%token <ival> INT

%token
  COMMA COLON SEMICOLON LPAREN RPAREN LBRACK RBRACK
  LBRACE RBRACE DOT
  PLUS MINUS TIMES DIVIDE EQ NEQ LT LE GT GE
  AND OR ASSIGN
  ARRAY IF THEN ELSE WHILE FOR TO DO LET IN END OF
  BREAK NIL
  FUNCTION VAR TYPE
  UMINUS

%start program
%left OR
%left AND
%nonassoc EQ NEQ LT LE GT GE
%left PLUS MINUS
%left TIMES DIVIDE
%left UMINUS


%%

/* This is a skeleton grammar file, meant to illustrate what kind of
 * declarations are necessary above the %% mark.  Students are expected
 *  to replace the two dummy productions below with an actual grammar.
 */

program:	exp;

exp:  ID                       {/* id */}
    | STRING                   {/* string (change to string when linkng with yylex) */}
    | INT                      {/* int literal */}
    | NIL                      {/* nil */}
    | lval                     {/* lval */}
    | MINUS exp  %prec UMINUS  {/* unary minus */}
    | exp PLUS exp             {/* addition */}
    | exp MINUS exp            {/* minus */}
    | exp TIMES exp            {/* times */}
    | exp DIVIDE exp           {/* divide */}
    | exp EQ exp               {/* equals */}
    | exp NEQ exp              {/* not equals */}
    | exp GT exp               {/* greater than */}
    | exp LT exp               {/* less than */}
    | exp GE exp               {/* greater than */}
    | exp LE exp               {/* less than */}
    | exp AND exp              {/* and */}
    | exp OR exp               {/* or */}
    | id LBRACE reclist RBRACE {/* id{exp{,exp} */}
    | LPAREN plist RPAREN      {/* (plist)  */}
    | LET decs IN expseq       {/* let decs in expseq */}
    | lval ASSIGN exp          {/* lval assign to exp */}
    | lval ASSIGN exp          {/* lval := exp */}
    | IF exp THEN exp ELSE exp {/* if exp then exp else exp */}
    | IF exp THEN exp          {/* if exp then exp */}
    | WHILE exp DO exp                 {/* while exp do exp */}
    | FOR id ASSIGN exp TO exp DO exp  {/* for id := to exp do exp */}
    | id LBRACK exp RBRACK OF exp      {/* id[exp] of exp */}
    ;

decs:  dec decs                 {}
     |  %empty
     ;

dec:  tydec                      {}
    | vardec                     {}
    | funcdec                    {}
    ;

tydec: TYPE id EQ ty             {}
      ;

ty:  id                          {}
   | LBRACE tyfields RBRACE      {}
   | LBRACE RBRACE               {}
   ;

tyfields: id COLON id cmma       {}
        ;

cmma:  COMMA tyfields            {}
     | %empty
     ;


vardec:  VAR id rettype ASSIGN exp  {}
       ;

rettype:  COLON id               {}
        | %empty
        ;

funcdec:  FUNCTION id LPAREN tyfields RPAREN rettype EQ exp     {/*MIGHT NEED TO REWRITE TO SPECIFY FUNC VS PROCEDURE*/}
        ;

lval:  id                      {}
     | lval DOT id             {}
     | lval LBRACK exp RBRACK  {}
     ;


plist:  exp SEMICOLON exp SEMICOLON plistitem {/*exp list inside paren exp*/}
      | %empty
      ;

plistitem:  exp SEMICOLON plistitem {}
          | %empty
          ;

reclist:  id EQ exp recend       {/*record declaration list */}
        | %empty
        ;

recend:  COMMA reclist           {}
       | %empty
       ;

expseq:  exp SEMICOLON expseq    {/*exp sequence*/}
       | %empty
       ;
