all:
	yacc -d minipy-lab.y
	lex minipy-lab.l
	g++ y.tab.c

y.tab.h:
	yacc -d minipy-lab.y

y.tab.c:
	yacc -d minipy-lab.y

lex.yy.c:
	lex minipy-lab.l

clean:
	rm y.tab.c y.tab.h lex.yy.c a.out