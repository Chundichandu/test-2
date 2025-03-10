# Define directories
SRC_DIR = src
BIN_DIR = bin
OUTPUT = $(BIN_DIR)/compiler

# Define source files
LEX_FILE = $(SRC_DIR)/compiler.l
YACC_FILE = $(SRC_DIR)/compiler.y

all: $(OUTPUT)

$(OUTPUT): $(LEX_FILE) $(YACC_FILE) | $(BIN_DIR)
	yacc -d $(YACC_FILE)
	lex $(LEX_FILE)
	gcc -o $(OUTPUT) lex.yy.c y.tab.c -lm

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

clean:
	rm -f $(OUTPUT) y.tab.h y.tab.c lex.yy.c