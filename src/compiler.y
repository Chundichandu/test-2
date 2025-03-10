%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <ctype.h>

    extern int yylineno;
    extern char* yytext;
    int get_symbol_value(char* name);

    typedef struct Node {
        char* token;
        struct Node* left;
        struct Node* right;
    } Node;

    Node* syntaxTreeRoot;

    typedef struct Symbol {
        char name[50];
        enum { INT_TYPE, FLOAT_TYPE } type;
        union {
            int intValue;
            float floatValue;
        } value;
    } Symbol;

    Symbol symbol_table[100];
    int symbol_count = 0;

    typedef struct ArraySymbol {
        char name[50];
        int size1, size2;
        int values[100][100];
    } ArraySymbol;

    ArraySymbol array_table[100];
    int array_count = 0;

    Node* createNode(char* token, Node* left, Node* right) {
        Node* newNode = (Node*)malloc(sizeof(Node));
        newNode->token = strdup(token);
        newNode->left = left;
        newNode->right = right;
        return newNode;
    }

    int get_symbol_value(char* name) {
        for (int i = 0; i < symbol_count; i++) {
            if (strcmp(symbol_table[i].name, name) == 0) {
                return symbol_table[i].value.intValue;
            }
        }
        printf("Error: Undefined variable '%s'\n", name);
        return 0;
    }

    void add_symbol(char* name, int type, float floatValue, int intValue) {
        for (int i = 0; i < symbol_count; i++) {
            if (strcmp(symbol_table[i].name, name) == 0) {
                if (type == INT_TYPE)
                    symbol_table[i].value.intValue = intValue;
                else
                    symbol_table[i].value.floatValue = floatValue;
                return;
            }
        }
        strcpy(symbol_table[symbol_count].name, name);
        symbol_table[symbol_count].type = type;
        if (type == INT_TYPE)
            symbol_table[symbol_count].value.intValue = intValue;
        else
            symbol_table[symbol_count].value.floatValue = floatValue;
        symbol_count++;
    }

    void printTree(Node* root, int level) {
    if (root == NULL) {
        printf("printTree: AST is NULL!\n");
        return;
    }
    
    for (int i = 0; i < level; i++) printf("  ");  
    printf("%s\n", root->token);

    printTree(root->left, level + 1);
    printTree(root->right, level + 1);
}


    void print_symbol_table() {
        printf("\nSymbol Table:\n--------------------\n");
        printf("Variable  | Type  | Value\n");
        printf("--------------------\n");
        for (int i = 0; i < symbol_count; i++) {
            printf("%-10s | %-5s | ", symbol_table[i].name, 
                   (symbol_table[i].type == INT_TYPE) ? "INT" : "FLOAT");
            if (symbol_table[i].type == INT_TYPE)
                printf("%d\n", symbol_table[i].value.intValue);
            else
                printf("%.2f\n", symbol_table[i].value.floatValue);
        }
        printf("--------------------\n");
    }

    void yyerror(const char* s) {
        fprintf(stderr, "Syntax Error: %s at line %d (token: '%s')\n", s, yylineno, yytext);
    }
%}

%union {
    int num;
    float fnum;
    char* s;
    struct Node* node;
}

%token BEGINDECL ENDDECL INTEGER FLOAT PRINT WRITE IF ELSE FOR DO WHILE
%token <s> ID
%token <num> NUM
%token <fnum> FLOAT_NUM
%left '+' '-'
%left '*' '/'
%type <node> expr stmt stmt_list for_stmt if_stmt do_while_stmt
%type <s> id_list

%%
program:
    BEGINDECL decl_list ENDDECL stmt_list { printf("Parsing successful!\n"); syntaxTreeRoot = $4; }
    ;

decl:
    INTEGER id_list ';' { }
    | FLOAT id_list ';' { }
    | INTEGER ID '[' NUM ']' '[' NUM ']' ';' { }
    ;

decl_list:
    decl_list decl
    | decl
    ;

id_list:
    id_list ',' ID { add_symbol($3, INT_TYPE, 0, 0); }
    | ID { add_symbol($1, INT_TYPE, 0, 0); }
    ;

stmt_list:
    stmt_list stmt { $$ = createNode("STMT_LIST", $1, $2); }
    | stmt { $$ = $1; }
    ;

stmt:
    ID '=' expr ';' { 
        int val = evaluateExpression($3);
        add_symbol($1, INT_TYPE, 0, val);
        $$ = createNode("=", createNode($1, NULL, NULL), $3);
    }
    | WRITE '(' expr ')' ';' { 
        int val = evaluateExpression($3);
        printf("%d\n", val);
        $$ = createNode("WRITE", $3, NULL);
    }
    | if_stmt
    | for_stmt
    | do_while_stmt
    ;

if_stmt:
    IF '(' expr ')' stmt ELSE stmt { $$ = createNode("IF", $3, createNode("THEN_ELSE", $5, $7)); }
    ;

for_stmt:
    FOR '(' ID '=' expr ';' expr ';' ID '=' expr ')' stmt { 
        $$ = createNode("FOR", createNode("INIT", createNode($3, NULL, NULL), $5), 
                        createNode("CONDITION", $7, createNode("UPDATE", createNode($9, NULL, NULL), $11))); 
    }
    ;

do_while_stmt:
    DO '{' stmt_list '}' WHILE '(' expr ')' ';' { 
        $$ = createNode("DO_WHILE", $3, $6);
    }
    ;

expr:
    NUM { 
        char buffer[20]; 
        sprintf(buffer, "%d", $1); 
        $$ = createNode(strdup(buffer), NULL, NULL); 
    }
    | FLOAT_NUM { 
        char buffer[20]; 
        sprintf(buffer, "%.2f", $1); 
        $$ = createNode(strdup(buffer), NULL, NULL); 
    }
    | ID { $$ = createNode(strdup($1), NULL, NULL); }
    | expr '+' expr { $$ = createNode("+", $1, $3); }
    | expr '-' expr { $$ = createNode("-", $1, $3); }
    | expr '*' expr { $$ = createNode("*", $1, $3); }
    | expr '/' expr { $$ = createNode("/", $1, $3); }
    | '(' expr ')' { $$ = $2; }
    ;
%%
int main() {
    printf("Starting the parser...\n"); // Debugging message

    if (yyparse() == 0) {  // If parsing is successful
        printf("Parsing complete. Syntax tree:\n");

        if (syntaxTreeRoot == NULL) {
            printf("Error: AST is NULL!\n");
        } else {
            printTree(syntaxTreeRoot, 0);  // Print AST
        }

        print_symbol_table();  // Print symbol table
    } else {
        printf("Parsing failed.\n");
    }
    
    return 0;
}



