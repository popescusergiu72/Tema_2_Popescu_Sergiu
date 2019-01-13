#!/bin/sh

yacc -d compl.y
lex compl.l
g++ lex.yy.c y.tab.c -o compl -lfl
./compl < in.txt