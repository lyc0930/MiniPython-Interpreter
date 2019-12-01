all: minipy-lab.y minipy-lab.l
	yacc -d -v minipy-lab.y
	lex minipy-lab.l
	g++ y.tab.c -o minipy.out

y.tab.h: minipy-lab.y
	yacc -d minipy-lab.y

y.tab.c: minipy-lab.y
	yacc -d minipy-lab.y

lex.yy.c: minipy-lab.l
	lex minipy-lab.l

y.output: minipy-lab.y
	yacc -v minipy-lab.y

clean:
	rm y.tab.c y.tab.h lex.yy.c minipy.out