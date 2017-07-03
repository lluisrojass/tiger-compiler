# Chapter 3

concerns itself with the parsing structure of the compiler. 

tiger.grm uses %empty directives to denote an empty production. Replace with /* empty */ to run using YACC.
The originally provided file omits token values in the %token definitions. This causes the parser to identify tokens incorrectly and can be fixed by explictily provides the values in the `tokens.h` file used by the lexer. 
