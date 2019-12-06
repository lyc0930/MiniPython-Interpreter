# MiniPython-Interpreter
## 编译原理与技术课程实验
## Principles and Techniques of Compiler
![](https://img.shields.io/badge/USTC-2019Fall-critical.svg?style=flat)

郑启龙老师编译原理与技术课程的实验，使用yacc与lex开发了一个交互式的迷你Python解释器。

## Function
1. 包含：
    - 数值(`INT`和`REAL`)
    - 串(`STRING_LITERAL`)
    - 列表(`List`)
    - ……

   等数据类型及变量定义
2. 包含以上类型间加`+`减`-`乘`*`除`/` `//`等基本运算
3. 支持取列表元素、取列表切片等操作
4. 支持列表的方法
    - `append()`
    - `count()`
    - `extend()`
    - `index()`
    - `insert()`
    - `pop()`
    - `remove()`
    - `reverse()`
5. 支持内置函数调用
    - `len()`
    - `list()`
    - `print()`
    - `range()`
    - `type()`
    - `quit()`
6. 终端设计
    - 左右方向键移动光标
    - 上下方向键调出输入历史
    - `Ctrl` + `C`实现键盘中断

***
## Environment
- Windows Subsystem for Linux: Ubuntu 18.04 LTS
```shell
$ uname -r
4.4.0-18362-Microsoft
```
- bison 3.0.4
```shell
$ bison --version
bison (GNU Bison) 3.0.4
Written by Robert Corbett and Richard Stallman.

Copyright (C) 2015 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```
- flex 2.6.4
```shell
$ flex --version
flex 2.6.4
```
## How to Build & Run
```shell
yacc -d minipy-lab.y
lex minipy-lab.l
g++ y.tab.c
./a.out
```
or use Make:
```shell
make all
```
To make clean:
```shell
make clean
```
***
## Timeline
- 10月底：完成相关数据结构（属性）的设计并提交备查
- 11月底：检查实验

## Members
- [嵇帆](https://git.lug.ustc.edu.cn/whitepuppy)
- [罗晏宸](https://github.com/lyc0930)
- [牛辛汉](https://git.lug.ustc.edu.cn/NXH)

## Reference
- [CPython](https://github.com/python/cpython/)
    - [Grammer](https://github.com/python/cpython/tree/master/Grammer)
    - [Parser](https://github.com/python/cpython/tree/master/Parser)
- [Python Docs](https://docs.python.org/3/)
    - [Literals](https://docs.python.org/3/reference/lexical_analysis.html#literals)