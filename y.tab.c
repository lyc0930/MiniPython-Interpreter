/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "3.0.4"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* Copy the first part of user declarations.  */
#line 1 "minipy-lab.y" /* yacc.c:339  */

    /* definition */
    #include <stdio.h>
    #include <ctype.h>
    #include <cmath>
    #include <iostream>
    #include <iomanip>
    #include <map>
    #include <string>
    #include <vector>
    #include "minipy-lab.h"
    using namespace std;
    typedef struct value
    {
        Type type;
        int integerValue;               /* value for int type */
        double realValue;               /* value for real type */
        string stringValue;             /* value for string type 或 方法 函数名称*/
        vector<struct value> listValue; /* value for list type */
        string variableName;            /* name of the Variable */

        // slice or item of List
        vector<struct value>::iterator begin; // slice 起始位置 或 item 坐标
        vector<struct value>::iterator end;
        int step;
    } Value;

    /*
        符号表 Symbol Table
        variableName(string) -> Value(not Variable)
    */
    map<string, Value> Symbol;

    #define YYSTYPE Value
    #include "lex.yy.c"
    void yyerror(string);

    // 变量值的输出函数
    void Print(Value);

    // 返回变量类型的字符串
    string TypeString(Value);

#line 110 "y.tab.c" /* yacc.c:339  */

# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* In a future release of Bison, this section will be replaced
   by #include "y.tab.h".  */
#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    ID = 258,
    INT = 259,
    REAL = 260,
    STRING_LITERAL = 261,
    DIV = 262,
    UMINUS = 263
  };
#endif
/* Tokens.  */
#define ID 258
#define INT 259
#define REAL 260
#define STRING_LITERAL 261
#define DIV 262
#define UMINUS 263

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */

/* Copy the second part of user declarations.  */

#line 177 "y.tab.c" /* yacc.c:358  */

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif

#ifndef YY_ATTRIBUTE
# if (defined __GNUC__                                               \
      && (2 < __GNUC__ || (__GNUC__ == 2 && 96 <= __GNUC_MINOR__)))  \
     || defined __SUNPRO_C && 0x5110 <= __SUNPRO_C
#  define YY_ATTRIBUTE(Spec) __attribute__(Spec)
# else
#  define YY_ATTRIBUTE(Spec) /* empty */
# endif
#endif

#ifndef YY_ATTRIBUTE_PURE
# define YY_ATTRIBUTE_PURE   YY_ATTRIBUTE ((__pure__))
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# define YY_ATTRIBUTE_UNUSED YY_ATTRIBUTE ((__unused__))
#endif

#if !defined _Noreturn \
     && (!defined __STDC_VERSION__ || __STDC_VERSION__ < 201112)
# if defined _MSC_VER && 1200 <= _MSC_VER
#  define _Noreturn __declspec (noreturn)
# else
#  define _Noreturn YY_ATTRIBUTE ((__noreturn__))
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(E) ((void) (E))
#else
# define YYUSE(E) /* empty */
#endif

#if defined __GNUC__ && 407 <= __GNUC__ * 100 + __GNUC_MINOR__
/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN \
    _Pragma ("GCC diagnostic push") \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")\
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# define YY_IGNORE_MAYBE_UNINITIALIZED_END \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif


#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYSIZE_T yynewbytes;                                            \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / sizeof (*yyptr);                          \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, (Count) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYSIZE_T yyi;                         \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  3
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   114

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  23
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  19
/* YYNRULES -- Number of rules.  */
#define YYNRULES  48
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  78

/* YYTRANSLATE[YYX] -- Symbol number corresponding to YYX as returned
   by yylex, with out-of-bounds checking.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   263

#define YYTRANSLATE(YYX)                                                \
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, without out-of-bounds checking.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      14,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,    12,     2,     2,
      19,    20,    10,     8,    22,     9,    21,    11,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    16,     2,
       2,    15,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    17,     2,    18,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,    13
};

#if YYDEBUG
  /* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,    53,    53,    58,    57,    70,    70,    72,    77,    81,
      85,   134,   138,   139,   143,   156,   169,   203,   204,   205,
     206,   211,   214,   229,   232,   236,   237,   493,   542,   660,
     666,   674,   679,   688,   693,   700,   702,   706,   711,   720,
     801,   837,   841,   907,   917,   928,   951,   952,   953
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || 0
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "ID", "INT", "REAL", "STRING_LITERAL",
  "DIV", "'+'", "'-'", "'*'", "'/'", "'%'", "UMINUS", "'\\n'", "'='",
  "':'", "'['", "']'", "'('", "')'", "'.'", "','", "$accept", "Start",
  "Lines", "$@1", "prompt", "stat", "assignExpr", "number", "factor",
  "atom", "slice_op", "sub_expr", "atom_expr", "arglist", "List",
  "opt_comma", "List_items", "add_expr", "mul_expr", YY_NULLPTR
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[NUM] -- (External) token number corresponding to the
   (internal) symbol number NUM (which must be that of a token).  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,    43,    45,
      42,    47,    37,   263,    10,    61,    58,    91,    93,    40,
      41,    46,    44
};
# endif

#define YYPACT_NINF -15

#define yypact_value_is_default(Yystate) \
  (!!((Yystate) == (-15)))

#define YYTABLE_NINF -7

#define yytable_value_is_error(Yytable_value) \
  0

  /* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
     STATE-NUM.  */
static const yytype_int8 yypact[] =
{
     -15,    19,    58,   -15,    -6,    65,   -15,   -15,   -15,   -15,
     -15,    89,    89,   -15,     8,    82,    10,   -15,   -15,   -15,
     -15,    34,   -15,    20,    97,   -15,    59,   -15,   -15,   -15,
      12,    20,    94,    25,   -15,    82,    82,     1,    27,    82,
      82,    82,    82,    82,    82,    82,    30,   -15,   -15,   -15,
     -15,    41,    38,   -15,    28,    20,   -15,    97,    97,   -15,
     -15,   -15,   -15,    20,   -15,   -15,    82,   -15,    82,    45,
      67,    20,    20,   -15,    82,    63,    20,   -15
};

  /* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
     Performed when YYTABLE does not specify something else to do.  Zero
     means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       8,     0,     0,     1,     0,     2,     7,    17,    12,    13,
      18,     0,     0,     8,     0,     0,     0,     9,    20,    48,
      25,    16,    19,    11,    41,    14,    16,    15,     5,    33,
      35,    37,     0,    41,     3,     0,    23,     0,     0,     0,
       0,     0,     0,     0,     0,    36,     0,    46,    47,     8,
      10,     0,    24,    30,    35,    31,    29,    39,    40,    44,
      42,    43,    45,    38,    34,     4,    23,    27,    36,     0,
      21,    24,    32,    28,     0,     0,    22,    26
};

  /* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
     -15,   -15,   -15,   -15,   -11,   -15,    54,   -15,    99,   -15,
     -15,    39,    -2,   -15,   -15,    42,   -15,   -14,     0
};

  /* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
      -1,     1,     5,    49,     2,    16,    17,    18,    19,    20,
      75,    51,    26,    54,    22,    46,    30,    23,    24
};

  /* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
     positive, shift that token.  If negative, reduce the rule whose
     number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int8 yytable[] =
{
      31,    32,    28,    21,     7,     8,     9,    10,     6,    11,
      12,     7,     8,     9,    10,    33,    11,    12,    14,     3,
      15,    53,    52,    55,    34,    14,    29,    15,    39,    40,
      56,    63,    41,    21,    45,    42,    43,    44,    65,    57,
      58,    59,    60,    61,    62,    48,    39,    40,    64,    35,
      68,    36,    71,    37,    72,    38,    67,    66,    -6,     4,
      76,    -6,    -6,    -6,    -6,    73,    -6,    -6,     7,     8,
       9,    10,    -6,    11,    12,    -6,    36,    -6,    37,    13,
      38,    77,    14,    74,    15,     7,     8,     9,    10,    50,
      11,    12,     7,     8,     9,    10,    69,    11,    12,    14,
       0,    15,    39,    40,    41,    70,    14,    42,    43,    44,
      25,    27,     0,     0,    47
};

static const yytype_int8 yycheck[] =
{
      14,    15,    13,     5,     3,     4,     5,     6,    14,     8,
       9,     3,     4,     5,     6,    15,     8,     9,    17,     0,
      19,    20,    36,    37,    14,    17,    18,    19,     8,     9,
       3,    45,     7,    35,    22,    10,    11,    12,    49,    39,
      40,    41,    42,    43,    44,    20,     8,     9,    18,    15,
      22,    17,    66,    19,    68,    21,    18,    16,     0,     1,
      74,     3,     4,     5,     6,    20,     8,     9,     3,     4,
       5,     6,    14,     8,     9,    17,    17,    19,    19,    14,
      21,    18,    17,    16,    19,     3,     4,     5,     6,    35,
       8,     9,     3,     4,     5,     6,    54,     8,     9,    17,
      -1,    19,     8,     9,     7,    66,    17,    10,    11,    12,
      11,    12,    -1,    -1,    20
};

  /* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
     symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,    24,    27,     0,     1,    25,    14,     3,     4,     5,
       6,     8,     9,    14,    17,    19,    28,    29,    30,    31,
      32,    35,    37,    40,    41,    31,    35,    31,    27,    18,
      39,    40,    40,    41,    14,    15,    17,    19,    21,     8,
       9,     7,    10,    11,    12,    22,    38,    20,    20,    26,
      29,    34,    40,    20,    36,    40,     3,    41,    41,    41,
      41,    41,    41,    40,    18,    27,    16,    18,    22,    38,
      34,    40,    40,    20,    16,    33,    40,    18
};

  /* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    23,    24,    26,    25,    25,    25,    25,    27,    28,
      29,    29,    30,    30,    31,    31,    31,    32,    32,    32,
      32,    33,    33,    34,    34,    35,    35,    35,    35,    35,
      35,    36,    36,    37,    37,    38,    38,    39,    39,    40,
      40,    40,    41,    41,    41,    41,    41,    41,    41
};

  /* YYR2[YYN] -- Number of symbols on the right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     2,     0,     5,     3,     0,     2,     0,     1,
       3,     1,     1,     1,     2,     2,     1,     1,     1,     1,
       1,     0,     2,     0,     1,     1,     7,     4,     5,     3,
       3,     1,     3,     2,     4,     0,     1,     1,     3,     3,
       3,     1,     3,     3,     3,     3,     3,     3,     1
};


#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)
#define YYEMPTY         (-2)
#define YYEOF           0

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                  \
do                                                              \
  if (yychar == YYEMPTY)                                        \
    {                                                           \
      yychar = (Token);                                         \
      yylval = (Value);                                         \
      YYPOPSTACK (yylen);                                       \
      yystate = *yyssp;                                         \
      goto yybackup;                                            \
    }                                                           \
  else                                                          \
    {                                                           \
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;                                                  \
    }                                                           \
while (0)

/* Error token number */
#define YYTERROR        1
#define YYERRCODE       256



/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)

/* This macro is provided for backward compatibility. */
#ifndef YY_LOCATION_PRINT
# define YY_LOCATION_PRINT(File, Loc) ((void) 0)
#endif


# define YY_SYMBOL_PRINT(Title, Type, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Type, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*----------------------------------------.
| Print this symbol's value on YYOUTPUT.  |
`----------------------------------------*/

static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
{
  FILE *yyo = yyoutput;
  YYUSE (yyo);
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# endif
  YYUSE (yytype);
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyoutput, "%s %s (",
             yytype < YYNTOKENS ? "token" : "nterm", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yytype_int16 *yybottom, yytype_int16 *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yytype_int16 *yyssp, YYSTYPE *yyvsp, int yyrule)
{
  unsigned long int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       yystos[yyssp[yyi + 1 - yynrhs]],
                       &(yyvsp[(yyi + 1) - (yynrhs)])
                                              );
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif


#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
yystrlen (const char *yystr)
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
yystpcpy (char *yydest, const char *yysrc)
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
        switch (*++yyp)
          {
          case '\'':
          case ',':
            goto do_not_strip_quotes;

          case '\\':
            if (*++yyp != '\\')
              goto do_not_strip_quotes;
            /* Fall through.  */
          default:
            if (yyres)
              yyres[yyn] = *yyp;
            yyn++;
            break;

          case '"':
            if (yyres)
              yyres[yyn] = '\0';
            return yyn;
          }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into *YYMSG, which is of size *YYMSG_ALLOC, an error message
   about the unexpected token YYTOKEN for the state stack whose top is
   YYSSP.

   Return 0 if *YYMSG was successfully written.  Return 1 if *YYMSG is
   not large enough to hold the message.  In that case, also set
   *YYMSG_ALLOC to the required number of bytes.  Return 2 if the
   required number of bytes is too large to store.  */
static int
yysyntax_error (YYSIZE_T *yymsg_alloc, char **yymsg,
                yytype_int16 *yyssp, int yytoken)
{
  YYSIZE_T yysize0 = yytnamerr (YY_NULLPTR, yytname[yytoken]);
  YYSIZE_T yysize = yysize0;
  enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
  /* Internationalized format string. */
  const char *yyformat = YY_NULLPTR;
  /* Arguments of yyformat. */
  char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
  /* Number of reported tokens (one for the "unexpected", one per
     "expected"). */
  int yycount = 0;

  /* There are many possibilities here to consider:
     - If this state is a consistent state with a default action, then
       the only way this function was invoked is if the default action
       is an error action.  In that case, don't check for expected
       tokens because there are none.
     - The only way there can be no lookahead present (in yychar) is if
       this state is a consistent state with a default action.  Thus,
       detecting the absence of a lookahead is sufficient to determine
       that there is no unexpected or expected token to report.  In that
       case, just report a simple "syntax error".
     - Don't assume there isn't a lookahead just because this state is a
       consistent state with a default action.  There might have been a
       previous inconsistent state, consistent state with a non-default
       action, or user semantic action that manipulated yychar.
     - Of course, the expected token list depends on states to have
       correct lookahead information, and it depends on the parser not
       to perform extra reductions after fetching a lookahead from the
       scanner and before detecting a syntax error.  Thus, state merging
       (from LALR or IELR) and default reductions corrupt the expected
       token list.  However, the list is correct for canonical LR with
       one exception: it will still contain any token that will not be
       accepted due to an error action in a later state.
  */
  if (yytoken != YYEMPTY)
    {
      int yyn = yypact[*yyssp];
      yyarg[yycount++] = yytname[yytoken];
      if (!yypact_value_is_default (yyn))
        {
          /* Start YYX at -YYN if negative to avoid negative indexes in
             YYCHECK.  In other words, skip the first -YYN actions for
             this state because they are default actions.  */
          int yyxbegin = yyn < 0 ? -yyn : 0;
          /* Stay within bounds of both yycheck and yytname.  */
          int yychecklim = YYLAST - yyn + 1;
          int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
          int yyx;

          for (yyx = yyxbegin; yyx < yyxend; ++yyx)
            if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR
                && !yytable_value_is_error (yytable[yyx + yyn]))
              {
                if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
                  {
                    yycount = 1;
                    yysize = yysize0;
                    break;
                  }
                yyarg[yycount++] = yytname[yyx];
                {
                  YYSIZE_T yysize1 = yysize + yytnamerr (YY_NULLPTR, yytname[yyx]);
                  if (! (yysize <= yysize1
                         && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
                    return 2;
                  yysize = yysize1;
                }
              }
        }
    }

  switch (yycount)
    {
# define YYCASE_(N, S)                      \
      case N:                               \
        yyformat = S;                       \
      break
      YYCASE_(0, YY_("syntax error"));
      YYCASE_(1, YY_("syntax error, unexpected %s"));
      YYCASE_(2, YY_("syntax error, unexpected %s, expecting %s"));
      YYCASE_(3, YY_("syntax error, unexpected %s, expecting %s or %s"));
      YYCASE_(4, YY_("syntax error, unexpected %s, expecting %s or %s or %s"));
      YYCASE_(5, YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s"));
# undef YYCASE_
    }

  {
    YYSIZE_T yysize1 = yysize + yystrlen (yyformat);
    if (! (yysize <= yysize1 && yysize1 <= YYSTACK_ALLOC_MAXIMUM))
      return 2;
    yysize = yysize1;
  }

  if (*yymsg_alloc < yysize)
    {
      *yymsg_alloc = 2 * yysize;
      if (! (yysize <= *yymsg_alloc
             && *yymsg_alloc <= YYSTACK_ALLOC_MAXIMUM))
        *yymsg_alloc = YYSTACK_ALLOC_MAXIMUM;
      return 1;
    }

  /* Avoid sprintf, as that infringes on the user's name space.
     Don't have undefined behavior even if the translation
     produced a string with the wrong number of "%s"s.  */
  {
    char *yyp = *yymsg;
    int yyi = 0;
    while ((*yyp = *yyformat) != '\0')
      if (*yyp == '%' && yyformat[1] == 's' && yyi < yycount)
        {
          yyp += yytnamerr (yyp, yyarg[yyi++]);
          yyformat += 2;
        }
      else
        {
          yyp++;
          yyformat++;
        }
  }
  return 0;
}
#endif /* YYERROR_VERBOSE */

/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
{
  YYUSE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YYUSE (yytype);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}




/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;


/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    int yystate;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus;

    /* The stacks and their tools:
       'yyss': related to states.
       'yyvs': related to semantic values.

       Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* The state stack.  */
    yytype_int16 yyssa[YYINITDEPTH];
    yytype_int16 *yyss;
    yytype_int16 *yyssp;

    /* The semantic value stack.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs;
    YYSTYPE *yyvsp;

    YYSIZE_T yystacksize;

  int yyn;
  int yyresult;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken = 0;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;

#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  yyssp = yyss = yyssa;
  yyvsp = yyvs = yyvsa;
  yystacksize = YYINITDEPTH;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY; /* Cause a token to be read.  */
  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        YYSTYPE *yyvs1 = yyvs;
        yytype_int16 *yyss1 = yyss;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * sizeof (*yyssp),
                    &yyvs1, yysize * sizeof (*yyvsp),
                    &yystacksize);

        yyss = yyss1;
        yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yytype_int16 *yyss1 = yyss;
        union yyalloc *yyptr =
          (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
        if (! yyptr)
          goto yyexhaustedlab;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
                  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token.  */
  yychar = YYEMPTY;

  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 3:
#line 58 "minipy-lab.y" /* yacc.c:1646  */
    {
            Value temp;
            if ((yyvsp[-1]).type != None)
            {
                if ((yyvsp[-1]).type == Variable) /* 单独的变量 */
                    Print(Symbol.at((yyvsp[-1]).variableName));
                else
                    Print((yyvsp[-1]));
                cout << endl;
            }
        }
#line 1316 "y.tab.c" /* yacc.c:1646  */
    break;

  case 7:
#line 73 "minipy-lab.y" /* yacc.c:1646  */
    { yyerrok; }
#line 1322 "y.tab.c" /* yacc.c:1646  */
    break;

  case 8:
#line 77 "minipy-lab.y" /* yacc.c:1646  */
    { cout << "miniPy> "; }
#line 1328 "y.tab.c" /* yacc.c:1646  */
    break;

  case 10:
#line 86 "minipy-lab.y" /* yacc.c:1646  */
    {
            (yyval).type = None;
            Value temp;
            if ((yyvsp[0]).type == Variable)
                temp = Symbol.at((yyvsp[0]).variableName);
            else
                temp = (yyvsp[0]);
            vector<struct value> temp_for_string = vector<struct value>();
            Value temp_for_string_2; // 拆分字符串
            switch ((yyvsp[-2]).type)
            {
                case Variable:
                    Symbol[(yyvsp[-2]).variableName] = temp; /* 加入符号表或重新赋值 */
                    break;
                case ListItem:
                    *(yyvsp[-2]).begin = temp;
                    break;
                case ListSlice:
                    switch (temp.type)
                    {
                        case List:
                            Symbol[(yyvsp[-2]).variableName].listValue.erase((yyvsp[-2]).begin, (yyvsp[-2]).end);
                            Symbol[(yyvsp[-2]).variableName].listValue.insert((yyvsp[-2]).begin, temp.listValue.begin(), temp.listValue.end()); // 插入
                            break;
                        case ListSlice:
                            Symbol[(yyvsp[-2]).variableName].listValue.erase((yyvsp[-2]).begin, (yyvsp[-2]).end);
                            Symbol[(yyvsp[-2]).variableName].listValue.insert((yyvsp[-2]).begin, temp.begin, temp.end); // 插入
                            break;
                        case String:
                            temp_for_string_2.type = String;
                            for (int i = 0; i < temp.stringValue.length(); i++)
                            {
                                temp_for_string_2.stringValue = temp.stringValue[i];
                                temp_for_string.push_back(temp_for_string_2);
                            }
                            Symbol[(yyvsp[-2]).variableName].listValue.erase((yyvsp[-2]).begin, (yyvsp[-2]).end);
                            Symbol[(yyvsp[-2]).variableName].listValue.insert((yyvsp[-2]).begin, temp_for_string.begin(), temp_for_string.end()); // 插入
                            break;
                        default:
                            yyerror("TypeError: can only assign an iterable");
                            YYERROR;
                    }
                    break;
                default:
                    yyerror("SyntaxError: can't assign to literal");
                    YYERROR;
            }
        }
#line 1381 "y.tab.c" /* yacc.c:1646  */
    break;

  case 14:
#line 144 "minipy-lab.y" /* yacc.c:1646  */
    {
            (yyval).type = (yyvsp[0]).type;
            if ((yyvsp[0]).type == Integer)
                (yyval).integerValue = (yyvsp[0]).integerValue;
            else if ((yyvsp[0]).type == Real)
                (yyval).realValue = (yyvsp[0]).realValue;
            else
            {
                yyerror("TypeError: bad operand type for unary +: '"+ TypeString((yyvsp[0])) + "\'");
                YYERROR;
            }
        }
#line 1398 "y.tab.c" /* yacc.c:1646  */
    break;

  case 15:
#line 157 "minipy-lab.y" /* yacc.c:1646  */
    {
            (yyval).type = (yyvsp[0]).type;
            if ((yyvsp[0]).type == Integer)
                (yyval).integerValue = -(yyvsp[0]).integerValue;
            else if ((yyvsp[0]).type == Real)
                (yyval).realValue = -(yyvsp[0]).realValue;
            else
            {
                yyerror("TypeError: bad operand type for unary -: '"+ TypeString((yyvsp[0])) + "\'");
                YYERROR;
            }
        }
#line 1415 "y.tab.c" /* yacc.c:1646  */
    break;

  case 16:
#line 170 "minipy-lab.y" /* yacc.c:1646  */
    {
            switch ((yyvsp[0]).type)
            {
                case Integer:
                case Real:
                case String:
                case List:
                    (yyval) = (yyvsp[0]);
                    break;
                case ListSlice:
                    (yyval).type = List;
                    (yyval).listValue = (yyvsp[0]).listValue;
                    break;
                case ListItem:
                    (yyval) = *(yyvsp[0]).begin;
                    break;
                case Variable:
                    if (Symbol.count((yyvsp[0]).variableName) == 1) // 已在变量表内
                        (yyval) = Symbol.at((yyvsp[0]).variableName); // 取变量内容，使用下标检查
                    else
                    {
                        yyerror("NameError: name '"+ (yyvsp[0]).variableName +"' is not defined");
                        YYERROR;
                    }
                    break;
                default:
                    yyerror("TypeError: not supported type");
                    YYERROR;
            }
        }
#line 1450 "y.tab.c" /* yacc.c:1646  */
    break;

  case 21:
#line 211 "minipy-lab.y" /* yacc.c:1646  */
    {
            (yyval).type = None;
        }
#line 1458 "y.tab.c" /* yacc.c:1646  */
    break;

  case 22:
#line 215 "minipy-lab.y" /* yacc.c:1646  */
    {
            (yyval).type = Integer;
            if ((yyvsp[0]).type == Integer)
                (yyval).integerValue = (yyvsp[0]).integerValue;
            else
            {
                yyerror("TypeError: slice indices must be integers or None");
                YYERROR;
            }
        }
#line 1473 "y.tab.c" /* yacc.c:1646  */
    break;

  case 23:
#line 229 "minipy-lab.y" /* yacc.c:1646  */
    {
            (yyval).type = None;
        }
#line 1481 "y.tab.c" /* yacc.c:1646  */
    break;

  case 26:
#line 238 "minipy-lab.y" /* yacc.c:1646  */
    {
            int begin, end, step;

            if ((yyvsp[-1]).type == None) // 默认步长
                step = 1;
            else if ((yyvsp[-1]).type == Integer)
                step = (yyvsp[-1]).integerValue;
            else
            {
                yyerror("TypeError: slice indices must be integers or None");
                YYERROR;
            }

            switch ((yyvsp[-6]).type)
            {
                case String:
                    (yyval).type = String;
                    (yyval).stringValue = "";

                    if (step > 0)
                    {
                        if ((yyvsp[-4]).type == None) // 默认起始
                            begin = 0;
                        else if ((yyvsp[-4]).type == Integer)
                            begin = (yyvsp[-4]).integerValue;
                        else
                        {
                            yyerror("TypeError: slice indices must be integers or None");
                            YYERROR;
                        }

                        if ((yyvsp[-2]).type == None) // 默认结束
                            end = (yyvsp[-6]).stringValue.length();
                        else if ((yyvsp[-2]).type == Integer)
                            end = (yyvsp[-2]).integerValue;
                        else
                        {
                            yyerror("TypeError: slice indices must be integers or None");
                            YYERROR;
                        }

                        for (int i = begin; i < end; i += step)
                            (yyval).stringValue += (yyvsp[-6]).stringValue[i]; // 逐个取子串
                    }
                    else if (step < 0) // 负步长
                    {
                        if ((yyvsp[-4]).type == None) // 默认起始
                            begin = (yyvsp[-6]).stringValue.length() - 1;
                        else if ((yyvsp[-4]).type == Integer)
                            begin = (yyvsp[-4]).integerValue;
                        else
                        {
                            yyerror("TypeError: slice indices must be integers or None");
                            YYERROR;
                        }

                        if ((yyvsp[-2]).type == None) // 默认结束
                            end = -1;
                        else if ((yyvsp[-2]).type == Integer)
                            end = (yyvsp[-2]).integerValue;
                        else
                        {
                            yyerror("TypeError: slice indices must be integers or None");
                            YYERROR;
                        }

                        for (int i = begin; i > end; i += step)
                            (yyval).stringValue += (yyvsp[-6]).stringValue[i]; // 逐个取子串
                    }
                    break;
                case List:
                    (yyval).type = List; // 列表元素类型
                    (yyval).listValue = vector<struct value>();
                    if (step > 0)
                    {
                        if ((yyvsp[-4]).type == None) // 默认起始
                            begin = 0;
                        else if ((yyvsp[-4]).type == Integer)
                            begin = (yyvsp[-4]).integerValue;
                        else
                        {
                            yyerror("TypeError: slice indices must be integers or None");
                            YYERROR;
                        }

                        if ((yyvsp[-2]).type == None) // 默认结束
                            end = (yyvsp[-6]).listValue.size();
                        else if ((yyvsp[-2]).type == Integer)
                            end = (yyvsp[-2]).integerValue;
                        else
                        {
                            yyerror("TypeError: slice indices must be integers or None");
                            YYERROR;
                        }

                        for (vector<struct value>::iterator i = (yyvsp[-6]).listValue.begin() + begin; i != (yyvsp[-6]).listValue.begin() + end; i += step)
                            (yyval).listValue.push_back(*i); // 逐个取元素
                    }
                    else if (step < 0)
                    {
                        if ((yyvsp[-4]).type == None) // 默认起始
                            begin = (yyvsp[-6]).listValue.size() - 1;
                        else if ((yyvsp[-4]).type == Integer)
                            begin = (yyvsp[-4]).integerValue;
                        else
                        {
                            yyerror("TypeError: slice indices must be integers or None");
                            YYERROR;
                        }

                        if ((yyvsp[-2]).type == None) // 默认结束
                            end = -1;
                        else if ((yyvsp[-2]).type == Integer)
                            end = (yyvsp[-2]).integerValue;
                        else
                        {
                            yyerror("TypeError: slice indices must be integers or None");
                            YYERROR;
                        }

                        for (vector<struct value>::iterator i = (yyvsp[-6]).listValue.begin() + begin; i != (yyvsp[-6]).listValue.begin() + end; i += step)
                            (yyval).listValue.push_back(*i); // 逐个取元素
                    }
                    break;
                case Variable:
                    if ((Symbol.count((yyvsp[-6]).variableName) == 1)) // 已在变量表内
                    {
                        switch (Symbol.at((yyvsp[-6]).variableName).type)
                        {
                            case String:
                                (yyval).type = String;
                                (yyval).stringValue = "";

                                if (step > 0)
                                {
                                    if ((yyvsp[-4]).type == None) // 默认起始
                                        begin = 0;
                                    else if ((yyvsp[-4]).type == Integer)
                                        begin = (yyvsp[-4]).integerValue;
                                    else
                                    {
                                        yyerror("TypeError: slice indices must be integers or None");
                                        YYERROR;
                                    }

                                    if ((yyvsp[-2]).type == None) // 默认结束
                                        end = Symbol.at((yyvsp[-6]).variableName).stringValue.length();
                                    else if ((yyvsp[-2]).type == Integer)
                                        end = (yyvsp[-2]).integerValue;
                                    else
                                    {
                                        yyerror("TypeError: slice indices must be integers or None");
                                        YYERROR;
                                    }
                                    for (int i = begin; i < end; i += step)
                                        (yyval).stringValue += Symbol.at((yyvsp[-6]).variableName).stringValue[i]; // 逐个取子串
                                }
                                else if (step < 0) // 负步长
                                {
                                    if ((yyvsp[-4]).type == None) // 默认起始
                                        begin = Symbol.at((yyvsp[-6]).variableName).stringValue.length() - 1;
                                    else if ((yyvsp[-4]).type == Integer)
                                        begin = (yyvsp[-4]).integerValue;
                                    else
                                    {
                                        yyerror("TypeError: slice indices must be integers or None");
                                        YYERROR;
                                    }

                                    if ((yyvsp[-2]).type == None) // 默认结束
                                        end = -1;
                                    else if ((yyvsp[-2]).type == Integer)
                                        end = (yyvsp[-2]).integerValue;
                                    else
                                    {
                                        yyerror("TypeError: slice indices must be integers or None");
                                        YYERROR;
                                    }

                                    for (int i = begin; i > end; i += step)
                                        (yyval).stringValue += Symbol.at((yyvsp[-6]).variableName).stringValue[i]; // 逐个取子串
                                }
                                break;
                            case List:
                                (yyval).type = ListSlice; // 列表元素类型
                                (yyval).variableName = (yyvsp[-6]).variableName;
                                (yyval).listValue = vector<struct value>();
                                if (step > 0)
                                {
                                    if ((yyvsp[-4]).type == None) // 默认起始
                                        (yyval).begin = Symbol.at((yyvsp[-6]).variableName).listValue.begin();
                                    else if ((yyvsp[-4]).type == Integer)
                                        (yyval).begin = Symbol.at((yyvsp[-6]).variableName).listValue.begin() + (yyvsp[-4]).integerValue;
                                    else
                                    {
                                        yyerror("TypeError: slice indices must be integers or None");
                                        YYERROR;
                                    }

                                    if ((yyvsp[-2]).type == None) // 默认结束
                                        (yyval).end = Symbol.at((yyvsp[-6]).variableName).listValue.end();
                                    else if ((yyvsp[-2]).type == Integer)
                                        (yyval).end = Symbol.at((yyvsp[-6]).variableName).listValue.begin() + (yyvsp[-2]).integerValue;
                                    else
                                    {
                                        yyerror("TypeError: slice indices must be integers or None");
                                        YYERROR;
                                    }

                                    for (vector<struct value>::iterator i = (yyval).begin; i != (yyval).end; i += step)
                                        (yyval).listValue.push_back(*i); // 逐个取子串

                                }
                                else if (step < 0)
                                {
                                    if ((yyvsp[-4]).type == None) // 默认起始
                                        (yyval).begin = Symbol.at((yyvsp[-6]).variableName).listValue.end() - 1;
                                    else if ((yyvsp[-4]).type == Integer)
                                        (yyval).begin = Symbol.at((yyvsp[-6]).variableName).listValue.begin() + (yyvsp[-4]).integerValue;
                                    else
                                    {
                                        yyerror("TypeError: slice indices must be integers or None");
                                        YYERROR;
                                    }

                                    if ((yyvsp[-2]).type == None) // 默认结束
                                        (yyval).end = Symbol.at((yyvsp[-6]).variableName).listValue.begin() - 1;
                                    else if ((yyvsp[-2]).type == Integer)
                                        (yyval).end = Symbol.at((yyvsp[-6]).variableName).listValue.begin() + (yyvsp[-2]).integerValue;
                                    else
                                    {
                                        yyerror("TypeError: slice indices must be integers or None");
                                        YYERROR;
                                    }

                                    for (vector<struct value>::iterator i = (yyval).begin; i != (yyval).end; i += step)
                                        (yyval).listValue.push_back(*i); // 逐个取子串
                                }
                                break;
                            default:
                                yyerror("TypeError: '"+ TypeString(Symbol.at((yyvsp[-6]).variableName)) +"' object is not subscriptable");
                                YYERROR;
                        }
                    }
                    else
                    {
                        yyerror("NameError: name '" + (yyvsp[-6]).variableName + "' is not defined");
                        YYERROR;
                    }
                    break;
                default:
                    yyerror("TypeError: '"+ TypeString((yyvsp[-6])) +"' object is not subscriptable");
                    YYERROR;
            }
        }
#line 1741 "y.tab.c" /* yacc.c:1646  */
    break;

  case 27:
#line 494 "minipy-lab.y" /* yacc.c:1646  */
    {
            if ((yyvsp[-1]).type == Integer)
            {
                switch ((yyvsp[-3]).type)
                {
                    case String:
                        (yyval).type = String;
                        (yyval).stringValue = (yyvsp[-3]).stringValue[(yyvsp[-1]).integerValue]; // 字符和字符串同等
                        break;
                    case List:
                        (yyval).type = ListItem; // 列表元素类型
                        (yyval).begin = (yyvsp[-3]).listValue.begin() + (yyvsp[-1]).integerValue; // 取列表元素地址
                        break;
                    case Variable:
                        if ((Symbol.count((yyvsp[-3]).variableName) == 1)) // 已在变量表内
                        {
                            switch (Symbol.at((yyvsp[-3]).variableName).type)
                            {
                                case String:
                                    (yyval).type = String;
                                    (yyval).stringValue = Symbol.at((yyvsp[-3]).variableName).stringValue[(yyvsp[-1]).integerValue]; // 字符和字符串同等
                                    break;
                                case List:
                                    (yyval).type = ListItem; // 列表元素类型
                                    (yyval).begin = Symbol.at((yyvsp[-3]).variableName).listValue.begin() + (yyvsp[-1]).integerValue; // 取列表元素地址
                                    break;
                                default:
                                    yyerror("TypeError: '"+ TypeString(Symbol.at((yyvsp[-3]).variableName)) +"' object is not subscriptable");
                                    YYERROR;
                            }
                        }
                        else
                        {
                            yyerror("NameError: name '" + (yyvsp[-3]).variableName + "' is not defined");
                            YYERROR;
                        }
                        break;
                    default:
                        yyerror("TypeError: '"+ TypeString((yyvsp[-3])) +"' object is not subscriptable");
                        YYERROR;
                }
            }
            else
            {
                yyerror("TypeError: list indices must be integers or slices, not " + TypeString((yyvsp[-1])));
                YYERROR;
            }
        }
#line 1794 "y.tab.c" /* yacc.c:1646  */
    break;

  case 28:
#line 543 "minipy-lab.y" /* yacc.c:1646  */
    {
            if ((yyvsp[-4]).stringValue == "append") // append方法
            {
                (yyval).type = None;
                if (Symbol.at((yyvsp[-4]).variableName).type == List)
                {
                    if ((yyvsp[-2]).listValue.size() == 1) // append 有且仅有1个参数
                    {
                        Symbol.at((yyvsp[-4]).variableName).listValue.push_back(*(yyvsp[-2]).listValue.begin());
                    }
                }
            }
            else if ((yyvsp[-4]).variableName == "print") // print函数
            {
                (yyval).type = None;
                for (vector<struct value>::iterator i = (yyvsp[-2]).listValue.begin(); i != (yyvsp[-2]).listValue.end(); i++)
                {
                    if ((*i).type == None)
                        cout << "None";
                    else
                        Print(*i);
                    if (i != (yyvsp[-2]).listValue.end() - 1)
                        cout << ' ';
                }
                cout << endl;
            }
            else if ((yyvsp[-4]).variableName == "range") // range函数
            {
                (yyval).type = List;
                (yyval).listValue = vector<struct value>();
                Value temp;
                temp.type = Integer; // 整数列表

                int begin, end, step;

                if ((yyvsp[-2]).listValue.size() == 1 || (yyvsp[-2]).listValue.size() == 2) // 默认步长
                    step = 1;
                else if ((yyvsp[-2]).listValue.size() == 3)
                    step = (yyvsp[-2]).listValue[2].integerValue; // 第三个参数
                else
                {
                    // yyerror(); // TODO @NXH ， 2 或 3 个参数
                }

                if (step > 0)
                {
                    if ((yyvsp[-2]).listValue.size() == 1) // 仅一个参数：从0到参数
                    {
                        begin = 0;
                        end = (yyvsp[-2]).listValue[0].integerValue;
                    }
                    else if ((yyvsp[-2]).listValue.size() == 2 || (yyvsp[-2]).listValue.size() == 3)
                    {
                        begin = (yyvsp[-2]).listValue[0].integerValue;
                        end = (yyvsp[-2]).listValue[1].integerValue;
                    }
                    for (temp.integerValue = begin; temp.integerValue < end; temp.integerValue+=step)
                        (yyval).listValue.push_back(temp);
                }
                else if (step < 0) // 一定有3个参数
                {
                    begin = (yyvsp[-2]).listValue[0].integerValue;
                    end = (yyvsp[-2]).listValue[1].integerValue;
                    for (temp.integerValue = begin; temp.integerValue > end; temp.integerValue+=step)
                        (yyval).listValue.push_back(temp);
                }
            }
            else if ((yyvsp[-4]).variableName == "list") // list函数
            {
                (yyval).type = List;

                if ((yyvsp[-2]).listValue.size() == 1) // list 有且仅有1个参数
                {
                    Value temp;
                    Value temp_2; // 拆分字符串

                    if ((*(yyvsp[-2]).listValue.begin()).type == Variable) // 变量替换为实体
                    {
                        if (Symbol.count((*(yyvsp[-2]).listValue.begin()).variableName) == 1) // 已在变量表中
                            temp = Symbol.at((*(yyvsp[-2]).listValue.begin()).variableName);
                        else
                        {
                            yyerror("NameError: name '" + (*(yyvsp[-2]).listValue.begin()).variableName + "' is not defined");
                            YYERROR;
                        }
                    }
                    else
                        temp = (*(yyvsp[-2]).listValue.begin());

                    switch (temp.type)
                    {
                        case String:
                            (yyval).listValue = vector<struct value>();
                            temp_2.type = String;
                            for (int i = 0; i < temp.stringValue.length(); i++)
                            {
                                temp_2.stringValue = temp.stringValue[i];
                                (yyval).listValue.push_back(temp_2);
                            }
                            break;
                        case List:
                            (yyval).listValue = vector<struct value>(temp.listValue);
                            break;
                        default:
                        {
                            yyerror("TypeError: '"+TypeString(temp)+"' object is not iterable");
                            YYERROR;
                        }
                    }
                }
                else
                {
                    yyerror("TypeError: list expected at most 1 arguments, got " + to_string((yyvsp[-2]).listValue.size()));
                    YYERROR;
                }
            }
        }
#line 1916 "y.tab.c" /* yacc.c:1646  */
    break;

  case 29:
#line 661 "minipy-lab.y" /* yacc.c:1646  */
    {
            (yyval).type = None;
            (yyval).variableName = (yyvsp[-2]).variableName; // 变量名
            (yyval).stringValue = (yyvsp[0]).variableName; // 属性或方法名
        }
#line 1926 "y.tab.c" /* yacc.c:1646  */
    break;

  case 30:
#line 667 "minipy-lab.y" /* yacc.c:1646  */
    {
            if ((yyvsp[-2]).variableName == "quit") // quit函数
                exit(0);
        }
#line 1935 "y.tab.c" /* yacc.c:1646  */
    break;

  case 31:
#line 675 "minipy-lab.y" /* yacc.c:1646  */
    {
        (yyval).type = List;
        (yyval).listValue = vector<struct value>(1, (yyvsp[0])); // 用列表“框柱”参数
    }
#line 1944 "y.tab.c" /* yacc.c:1646  */
    break;

  case 32:
#line 680 "minipy-lab.y" /* yacc.c:1646  */
    {
        (yyval).type = List;
        (yyvsp[-2]).listValue.push_back((yyvsp[0]));
        (yyval).listValue = vector<struct value>((yyvsp[-2]).listValue);
    }
#line 1954 "y.tab.c" /* yacc.c:1646  */
    break;

  case 33:
#line 689 "minipy-lab.y" /* yacc.c:1646  */
    {
        (yyval).type = List;
        (yyval).listValue = vector<struct value>();
    }
#line 1963 "y.tab.c" /* yacc.c:1646  */
    break;

  case 34:
#line 694 "minipy-lab.y" /* yacc.c:1646  */
    {
        (yyval).type = List;
        (yyval).listValue = vector<struct value>((yyvsp[-2]).listValue);
    }
#line 1972 "y.tab.c" /* yacc.c:1646  */
    break;

  case 37:
#line 707 "minipy-lab.y" /* yacc.c:1646  */
    {
        (yyval).type = List;
        (yyval).listValue = vector<struct value>(1, (yyvsp[0])); // 用列表“框柱”变量
    }
#line 1981 "y.tab.c" /* yacc.c:1646  */
    break;

  case 38:
#line 712 "minipy-lab.y" /* yacc.c:1646  */
    {
        (yyval).type = List;
        (yyvsp[-2]).listValue.push_back((yyvsp[0]));
        (yyval).listValue = vector<struct value>((yyvsp[-2]).listValue);
    }
#line 1991 "y.tab.c" /* yacc.c:1646  */
    break;

  case 39:
#line 721 "minipy-lab.y" /* yacc.c:1646  */
    {
            switch((yyvsp[-2]).type)
            {
                case Integer:
                    switch((yyvsp[0]).type)
                    {
                        case Integer:
                            (yyval).type = Integer;
                            (yyval).integerValue = (yyvsp[-2]).integerValue + (yyvsp[0]).integerValue;
                            break;
                        case Real:
                            (yyval).type = Real;
                            (yyvsp[-2]).realValue = (double) (yyvsp[-2]).integerValue;
                            (yyval).realValue = (yyvsp[-2]).realValue + (yyvsp[0]).realValue;
                            break;
                        case List:
                            (yyval).type = List;
                            (yyval).listValue = vector<struct value>((yyvsp[0]).listValue);
                            (yyval).listValue.insert((yyval).listValue.begin(), (yyvsp[-2])); // 在头部插入
                            break;
                        // default: yyerror(); // TODO @NXH
                    }
                    break;
                case Real:
                    switch((yyvsp[0]).type)
                    {
                        case Integer:
                            (yyval).type = Real;
                            (yyvsp[0]).realValue = (double) (yyvsp[0]).integerValue;
                            (yyval).realValue = (yyvsp[-2]).realValue + (yyvsp[0]).realValue;
                            break;
                        case Real:
                            (yyval).type = Real;
                            (yyval).realValue = (yyvsp[-2]).realValue + (yyvsp[0]).realValue;
                            break;
                        case List:
                            (yyval).type = List;
                            (yyval).listValue = vector<struct value>((yyvsp[0]).listValue);
                            (yyval).listValue.insert((yyval).listValue.begin(), (yyvsp[-2])); // 在头部插入
                            break;
                        // default: yyerror(); // TODO @NXH
                    }
                    break;
                case String:
                    switch((yyvsp[0]).type)
                    {
                        case String:
                            (yyval).type = String;
                            (yyval).stringValue = (yyvsp[-2]).stringValue + (yyvsp[0]).stringValue;
                            break;
                        case List:
                            (yyval).type = List;
                            (yyval).listValue = vector<struct value>((yyvsp[0]).listValue);
                            (yyval).listValue.insert((yyval).listValue.begin(), (yyvsp[-2])); // 在头部插入
                            break;
                        // default: yyerror(); // TODO @NXH
                    }
                    break;
                case List:
                    (yyval).type = List;
                    (yyval).listValue = vector<struct value>((yyvsp[-2]).listValue);
                    switch((yyvsp[0]).type)
                    {
                        case Integer:
                            (yyval).listValue.insert((yyval).listValue.end(), (yyvsp[0])); // 在尾部插入
                            break;
                        case Real:
                            (yyval).listValue.insert((yyval).listValue.end(), (yyvsp[0])); // 在尾部插入
                            break;
                        case String:
                            (yyval).listValue.insert((yyval).listValue.end(), (yyvsp[0])); // 在尾部插入
                            break;
                        case List:
                            (yyval).listValue.insert((yyval).listValue.end(), (yyvsp[0]).listValue.begin(), (yyvsp[0]).listValue.end()); // 在尾部插入
                            break;
                        // default: yyerror(); // TODO @NXH
                    }
                // default: yyerror(); // TODO @NXH
            }
        }
#line 2076 "y.tab.c" /* yacc.c:1646  */
    break;

  case 40:
#line 802 "minipy-lab.y" /* yacc.c:1646  */
    {
            switch((yyvsp[-2]).type)
            {
                case Integer:
                    switch((yyvsp[0]).type)
                    {
                        case Integer:
                            (yyval).type = Integer;
                            (yyval).integerValue = (yyvsp[-2]).integerValue - (yyvsp[0]).integerValue;
                            break;
                        case Real:
                            (yyval).type = Real;
                            (yyvsp[-2]).realValue = (double) (yyvsp[-2]).integerValue;
                            (yyval).realValue = (yyvsp[-2]).realValue - (yyvsp[0]).realValue;
                            break;
                        // default: yyerror(); // TODO @NXH
                    }
                    break;
                case Real:
                    switch((yyvsp[0]).type)
                    {
                        case Integer:
                            (yyval).type = Real;
                            (yyvsp[0]).realValue = (double) (yyvsp[0]).integerValue;
                            (yyval).realValue = (yyvsp[-2]).realValue - (yyvsp[0]).realValue;
                            break;
                        case Real:
                            (yyval).type = Real;
                            (yyval).realValue = (yyvsp[-2]).realValue - (yyvsp[0]).realValue;
                            break;
                        // default: yyerror(); // TODO @NXH
                    }
                    break;
            }
        }
#line 2116 "y.tab.c" /* yacc.c:1646  */
    break;

  case 42:
#line 842 "minipy-lab.y" /* yacc.c:1646  */
    {
            switch((yyvsp[-2]).type)
            {
                case Integer:
                    switch((yyvsp[0]).type)
                    {
                        case Integer:
                            (yyval).type = Integer;
                            (yyval).integerValue = (yyvsp[-2]).integerValue * (yyvsp[0]).integerValue;
                            break;
                        case Real:
                            (yyval).type = Real;
                            (yyvsp[-2]).realValue = (double) (yyvsp[-2]).integerValue;
                            (yyval).realValue = (yyvsp[-2]).realValue * (yyvsp[0]).realValue;
                            break;
                        case List:
                            (yyval).type = List;
                            (yyval).listValue = vector<struct value>((yyvsp[0]).listValue);
                            for (int i = 1; i < (yyvsp[-2]).integerValue; i++)
                                (yyval).listValue.insert((yyval).listValue.end(), (yyvsp[0]).listValue.begin(), (yyvsp[0]).listValue.end()); // 循环插入
                            break;
                        // default: yyerror(); // TODO @NXH
                    }
                    break;
                case Real:
                    switch((yyvsp[0]).type)
                    {
                        case Integer:
                            (yyval).type = Real;
                            (yyvsp[0]).realValue = (double) (yyvsp[0]).integerValue;
                            (yyval).realValue = (yyvsp[-2]).realValue * (yyvsp[0]).realValue;
                            break;
                        case Real:
                            (yyval).type = Real;
                            (yyval).realValue = (yyvsp[-2]).realValue * (yyvsp[0]).realValue;
                            break;
                        // default: yyerror(); // TODO @NXH
                    }
                    break;
                case String:
                    switch((yyvsp[0]).type)
                    {
                        case Integer:
                            (yyval).type = String;
                            (yyval).stringValue = (yyvsp[-2]).stringValue;
                            for (int i = 1; i < (yyvsp[0]).integerValue; i++)
                                (yyval).stringValue += (yyvsp[-2]).stringValue;
                            break;
                        // default: yyerror(); // TODO @NXH
                    }
                    break;
                case List:
                    switch((yyvsp[0]).type)
                    {
                        case Integer:
                            (yyval).type = List;
                            (yyval).listValue = vector<struct value>((yyvsp[-2]).listValue);
                            for (int i = 1; i < (yyvsp[0]).integerValue; i++)
                                (yyval).listValue.insert((yyval).listValue.end(), (yyvsp[-2]).listValue.begin(), (yyvsp[-2]).listValue.end()); // 循环插入
                            break;
                        // default: yyerror(); // TODO @NXH
                    }
                // default: yyerror(); // TODO @NXH
            }
        }
#line 2186 "y.tab.c" /* yacc.c:1646  */
    break;

  case 43:
#line 908 "minipy-lab.y" /* yacc.c:1646  */
    {
            (yyval).type = Real;
            if ( (yyvsp[-2]).type == Integer )
                (yyvsp[-2]).realValue = (double) (yyvsp[-2]).integerValue;
            if ( (yyvsp[0]).type == Integer )
                (yyvsp[0]).realValue = (double) (yyvsp[0]).integerValue;
            (yyval).realValue = (yyvsp[-2]).realValue / (yyvsp[0]).realValue;
            // default: yyerror(); // TODO @NXH
        }
#line 2200 "y.tab.c" /* yacc.c:1646  */
    break;

  case 44:
#line 918 "minipy-lab.y" /* yacc.c:1646  */
    {
            // 整除
            if ( (yyvsp[-2]).type == Real )
                (yyvsp[-2]).integerValue = round((yyvsp[-2]).realValue);
            if ( (yyvsp[0]).type == Real )
                (yyvsp[0]).integerValue = round((yyvsp[0]).realValue);
            (yyval).type = Integer;
            (yyval).integerValue = (yyvsp[-2]).integerValue / (yyvsp[0]).integerValue;
            // default: yyerror(); // TODO @NXH
        }
#line 2215 "y.tab.c" /* yacc.c:1646  */
    break;

  case 45:
#line 929 "minipy-lab.y" /* yacc.c:1646  */
    {
            if (((yyvsp[-2]).type == Integer) && ( (yyvsp[0]).type == Integer ))
            {
			    (yyval).type = Integer;
                (yyval).integerValue = (yyvsp[-2]).integerValue % (yyvsp[0]).integerValue;
                if ((yyvsp[-2]).integerValue * (yyvsp[0]).integerValue < 0) // 取余的符号问题
                    (yyval).integerValue += (yyvsp[0]).integerValue;
            }
            else
            {
		        (yyval).type = Real;
                if ( (yyvsp[-2]).type == Integer )
                    (yyvsp[-2]).realValue = (double) (yyvsp[-2]).integerValue;
                if ( (yyvsp[0]).type == Integer )
                    (yyvsp[0]).realValue = (double) (yyvsp[0]).integerValue;
                int temp = (int)((yyvsp[-2]).realValue / (yyvsp[0]).realValue); // 手动实现实数取余
                (yyval).realValue = (yyvsp[-2]).realValue - ((yyvsp[0]).realValue * temp);
                if ((yyvsp[-2]).realValue * (yyvsp[0]).realValue < 0)
                    (yyval).realValue += (yyvsp[0]).realValue;
            }
            // default: yyerror(); // TODO @NXH
        }
#line 2242 "y.tab.c" /* yacc.c:1646  */
    break;

  case 46:
#line 951 "minipy-lab.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[-1]); }
#line 2248 "y.tab.c" /* yacc.c:1646  */
    break;

  case 47:
#line 952 "minipy-lab.y" /* yacc.c:1646  */
    { (yyval) = (yyvsp[-1]); }
#line 2254 "y.tab.c" /* yacc.c:1646  */
    break;


#line 2258 "y.tab.c" /* yacc.c:1646  */
      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYEMPTY : YYTRANSLATE (yychar);

  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
# define YYSYNTAX_ERROR yysyntax_error (&yymsg_alloc, &yymsg, \
                                        yyssp, yytoken)
      {
        char const *yymsgp = YY_("syntax error");
        int yysyntax_error_status;
        yysyntax_error_status = YYSYNTAX_ERROR;
        if (yysyntax_error_status == 0)
          yymsgp = yymsg;
        else if (yysyntax_error_status == 1)
          {
            if (yymsg != yymsgbuf)
              YYSTACK_FREE (yymsg);
            yymsg = (char *) YYSTACK_ALLOC (yymsg_alloc);
            if (!yymsg)
              {
                yymsg = yymsgbuf;
                yymsg_alloc = sizeof yymsgbuf;
                yysyntax_error_status = 2;
              }
            else
              {
                yysyntax_error_status = YYSYNTAX_ERROR;
                yymsgp = yymsg;
              }
          }
        yyerror (yymsgp);
        if (yysyntax_error_status == 2)
          goto yyexhaustedlab;
      }
# undef YYSYNTAX_ERROR
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYTERROR;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#if !defined yyoverflow || YYERROR_VERBOSE
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  yystos[*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  return yyresult;
}
#line 956 "minipy-lab.y" /* yacc.c:1906  */


int main()
{
	return yyparse();
}

void yyerror(string s)
{
	cout << s << endl << "miniPy> ";
}

int yywrap()
{
	return 1;
}

void Print(Value x)
{
    switch(x.type)
    {
        case Integer:
            cout << x.integerValue;
            break;
        case Real:
            if (x.realValue - floor(x.realValue) == 0)
                cout << x.realValue <<".0";
            else
                cout << setprecision(15) << x.realValue;
            break;
        case String:
            cout << '\'' << x.stringValue << '\'';
            break;
        case List:
        case ListSlice: // Slice 的 listValue 也存储相应值
            cout << "[";
            for (vector<struct value>::iterator i = x.listValue.begin(); i != x.listValue.end(); i++)
            {
                Print(*i);
                if (i != x.listValue.end() - 1)
                    cout << ", ";
            }
            cout << "]";
            break;
        case ListItem:
            Print(*x.begin); // 输出元素
            break;
    }
}

string TypeString(Value x) // 将枚举类型返回字符串类型，用于错误信息
{
    switch (x.type)
    {
        case None:       // 赋值语句、列表方法等在python里没有输出
            return "None";
        case Integer:    // 整型
            return "int";
        case Real:       // 浮点型
            return "float";
        case String:     // 字符和字符串
            return "str";
        case List:       // 列表
            return "list";
        case Variable:   // 变量
            return TypeString(Symbol.at(x.variableName));
        case ListSlice:  // 列表切片
            return "list";
        case ListItem:   // 列表元素
            return TypeString(*x.begin);
        default:
            return "None";
    }
}
