/*
 * errormsg.c - functions used in all phases of the compiler to give
 *              error messages about the Tiger program.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "util.h"
#include "errormsg.h"


bool anyErrors= FALSE;

static string fileName = "";

// lineNum tells you the number of lines that we have covered. It gets incremented by a call
// to :func: EM_newline. It is not included in errormsg.h and is enclosed in this module. mainly used
// the EM_errorMsg func adn it is static global.

static int lineNum = 1;

// included in errormsg.h and is visible to the outside world.
// it gets modified with calls to adjust() which set it to the position in which
// the token we are viewing starts.
int EM_tokPos=0;

// the file which we are parsing.
// I do not know why this is here in the error message module.
extern FILE *yyin;
// typedef of intList struct as IntList
typedef struct intList {int i; struct intList *rest;} *IntList;

// constructor function for intList
static IntList intList(int i, IntList rest)
{
  IntList l= checked_malloc(sizeof *l);
  l->i=i; l->rest=rest;
  return l;
}
/* main IntList in this module. this file is a linked list which every new line encountered, adds
that line to the front of the linked list with the last position that the last
token on that line starts.
*/
static IntList linePos=NULL;

/* newline function which adds the last token in the line to the linePos linkedlist */
void EM_newline(void)
{
  lineNum++;
  linePos = intList(EM_tokPos, linePos);
}


void EM_error(int pos, char *message,...){
  va_list ap;
  IntList lines = linePos;
  int num=lineNum;
  anyErrors=TRUE;

  while (lines && lines->i >= pos)
  {
    lines=lines->rest; num--;
  }

  if (fileName) fprintf(stderr,"%s:",fileName);
  if (lines) fprintf(stderr,"%d.%d: ", num, pos-lines->i);
  va_start(ap,message);
  vfprintf(stderr, message, ap);
  va_end(ap);
  fprintf(stderr,"\n");

}

void EM_reset(string fname)
{
  anyErrors=FALSE; fileName=fname; lineNum=1;
  linePos=intList(0,NULL);
  yyin = fopen(fname,"r");
  if (!yyin) {EM_error(0,"cannot open"); exit(1);}
}
