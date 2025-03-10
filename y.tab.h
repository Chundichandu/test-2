#ifndef _yy_defines_h_
#define _yy_defines_h_

#define DECL 257
#define ENDDECL 258
#define BBEGIN 259
#define BEND 260
#define INTEGER 261
#define FLOAT 262
#define PRINT 263
#define WRITE 264
#define IF 265
#define ELSE 266
#define FOR 267
#define DO 268
#define WHILE 269
#define ID 270
#define NUM 271
#define FLOAT_NUM 272
#ifdef YYSTYPE
#undef  YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#endif
#ifndef YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
typedef union YYSTYPE {
    int num;
    float fnum;
    char* s;
    struct Node* node;
} YYSTYPE;
#endif /* !YYSTYPE_IS_DECLARED */
extern YYSTYPE yylval;

#endif /* _yy_defines_h_ */
