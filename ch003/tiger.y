%{
#include <stdio.h>
#include "util.h"
#include "errormsg.h"

int yylex(void);

void yyerror(char *s) {
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

%start program
%nonassoc OF DO
%nonassoc THEN
%nonassoc ELSE
%left SEMICOLON
%left ASSIGN
%left OR
%left AND
%nonassoc EQ NEQ LT LE GT GE
%left PLUS MINUS
%left TIMES DIVIDE
%left UMINUS

%%

program
  : exp
  ;

exp
  : LET decs IN expsec END
  | STRING
  | INT
  | NIL
  | assignment
  | ID LBRACK exp RBRACK OF exp
  | ID LBRACE recdecs RBRACE
  | ID LPAREN params RPAREN
  | ID LPAREN RPAREN
  | lval
  | arithmetic_expression
  | boolean_expression
  | comparison
  | LPAREN expsec RPAREN
  | MINUS exp %prec UMINUS
  | iteration
  | conditional
  | BREAK
  ;

iteration
  : WHILE exp DO exp
  | FOR ID ASSIGN exp TO exp DO exp
  ;

conditional
  : IF exp THEN exp ELSE exp
  | IF exp THEN exp
  ;

arithmetic_expression
  : exp PLUS exp
  | exp MINUS exp
  | exp TIMES exp
  | exp DIVIDE exp
  ;

boolean_expression
  : exp EQ exp
  | exp NEQ exp
  | exp GT exp
  | exp LT exp
  | exp GE exp
  | exp LE exp
  ;

comparison
  : exp AND exp
  | exp OR exp
  ;

assignment
  : lval ASSIGN exp
  ;

recdecs
  : recdecs COMMA ID EQ exp
  | ID EQ exp
  | %empty
  ;

lval
  : ID lvalue_tail
  ;

lvalue_tail
  : %empty
  | DOT ID lvalue_tail
  | LBRACK exp RBRACK lvalue_tail

expsec
  : expsec exp SEMICOLON
  | %empty
  ;

params
  : params COMMA exp
  | exp
  ;
decs
  : decs dec
  | %empty
  ;

dec
  : tydec
  | vardec
  | funcdec
  ;

tydec
  : TYPE ID EQ ty
  ;

ty
  : ID
  | LBRACE tyfields RBRACE
  | ARRAY OF ID
  ;

tyfields
  : tyfields COMMA ID COLON ID
  | ID COLON ID
  | %empty
  ;

vardec
  : VAR ID returntype ASSIGN exp
  ;

returntype
  : COLON ID
  | %empty
  ;

funcdec
  : FUNCTION ID LPAREN tyfields RPAREN returntype EQ exp
  ;
