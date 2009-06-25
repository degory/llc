<%include("/header.lsi");%>

<h4>L Language C-Style Syntax</h4>
L has two syntaxes. They're very similar and I may integrate both into the same parser in future. The difference between the two syntaxes is in how block statements are opened and closed. In the C-style syntax blocks are enclosed in curley braces { } whereas in the alternative syntax blocks are enclosed in keywords specific to the construct that the block appears in. 

<pre>
package : class_list

class_thing : class
            | struct
            | namespace
            | use
            | enumeration
            | import
            | pragma

pragma : PRAGMA identifier_list END_STATEMENT

class_list : class_thing
           | class_list class_thing

namespace : NAMESPACE name START_BLOCK END_BLOCK
          | NAMESPACE name START_BLOCK class_list END_BLOCK

use : USE name END_STATEMENT

class_specifiers : access_specifiers
                 |

import : IMPORT name END_STATEMENT
       | IMPORT constant_string END_STATEMENT

struct : class_specifiers STRUCT identifier class_body

class : class_specifiers CLASS identifier generic class_body
      | class_specifiers CLASS identifier generic EXTENDS name generic_super class_body

generic : OPEN_GENERIC plain_identifier_list CLOSE_GENERIC
        |

generic_super : OPEN_GENERIC type_list CLOSE_GENERIC
              |

enumeration : class_specifiers ENUM identifier START_BLOCK identifier_list END_BLOCK
            | class_specifiers ENUM identifier START_BLOCK END_BLOCK

class_body : START_BLOCK END_BLOCK
           | START_BLOCK class_body_declarations END_BLOCK

class_body_declarations : class_body_declaration
                        | class_body_declarations class_body_declaration

class_body_declaration : field_declaration
                       | method_declaration
                       | native_declaration
                       | access_specifiers field_declaration
                       | access_specifiers method_declaration
                       | access_specifiers native_declaration
                       | enumeration
                       | pragma

field_declaration : type identifier_list END_STATEMENT

native_declaration : NATIVE type identifier declare_arguments END_STATEMENT

method_declaration : type identifier declare_arguments block_statement
                   | type GET identifier block_statement
                   | SET identifier declare_arguments block_statement

declare_arguments : OPEN_PAREN declare_argument_list CLOSE_PAREN
                  | OPEN_PAREN CLOSE_PAREN

declare_argument_list : argument_declaration
                      | declare_argument_list COMMA argument_declaration

argument_declaration : type identifier

expression : expressionX

expressionX : expressionX BOOL_AND expression0
            | expressionX BOOL_OR expression0
            | expression0

expression0 : BOOL_NOT expression0
            | expressionA

expressionA : expressionA EQ expressionB
            | expressionA NE expressionB
            | expressionA GT expressionB
            | expressionA LT expressionB
            | expressionA GE expressionB
            | expressionA LE expressionB
            | expressionA OBJ_EQ expressionB
            | expressionA OBJ_NE expressionB
            | expressionB

expressionB : expressionB AND expressionC
            | expressionB OR expressionC
            | expressionB XOR expressionC
            | expressionC

expressionC : expressionC SHIFT_LEFT expression1
            | expressionC SHIFT_RIGHT expression1
            | expression1

expression1 : expression1 ADD expression2
            | expression1 SUB expression2
            | expression2

expression2 : expression2 MUL expression3
            | expression2 DIV expression3
            | expression2 MOD expression3
            | expression3

expression3 : unary_expression
            | NOT expression3

access_specifiers : access_specifiers access_specifier
                  | access_specifier

access_specifier : PUBLIC
                 | PRIVATE
                 | PROTECTED
                 | STATIC
                 | CONST

ident_assign : identifier
             | identifier ASSIGN expression

plain_identifier_list : identifier
                      | plain_identifier_list COMMA identifier

identifier_list : ident_assign
                | identifier_list COMMA ident_assign

empty_statement : END_STATEMENT

method_call_statement : method_call

labelled_statement : identifier COLON loop_statement
                   | loop_statement

loop_statement : foreach_statement
               | for_statement
               | do_statement
               | while_statement

do_statement : DO statement WHILE OPEN_PAREN expression CLOSE_PAREN END_STATEMENT

foreach_statement : FOREACH OPEN_PAREN type identifier END_STATEMENT expression CLOSE_PAREN statement
                  | FOREACH OPEN_PAREN VARIABLE identifier END_STATEMENT expression CLOSE_PAREN statement

for_statement : FOR OPEN_PAREN within_for_statement expression END_STATEMENT very_simple_statement CLOSE_PAREN statement
              | FOR OPEN_PAREN within_for_statement END_STATEMENT very_simple_statement CLOSE_PAREN statement
              | FOR OPEN_PAREN within_for_statement expression END_STATEMENT CLOSE_PAREN statement
              | FOR OPEN_PAREN within_for_statement END_STATEMENT CLOSE_PAREN statement

switch_statement : SWITCH OPEN_PAREN expression CLOSE_PAREN START_BLOCK case_list END_BLOCK
                 | SWITCH OPEN_PAREN expression CLOSE_PAREN START_BLOCK END_BLOCK

case_list : case
          | case_list case
          | default
          | case_list default

case : CASE expression_list COLON block_statement_list

default : DEFAULT COLON block_statement_list

if_then_statement : IF OPEN_PAREN expression CLOSE_PAREN statement

if_then_else_statement : IF OPEN_PAREN expression CLOSE_PAREN statement_inner ELSE statement

if_then_else_statement_inner : IF OPEN_PAREN expression CLOSE_PAREN statement_inner ELSE statement_inner

while_statement : WHILE OPEN_PAREN expression CLOSE_PAREN statement

while_statement_inner : WHILE OPEN_PAREN expression CLOSE_PAREN statement_inner

return_statement : RETURN END_STATEMENT
                 | RETURN expression END_STATEMENT

throw_statement : THROW expression END_STATEMENT

try_statement : TRY block_statement catches
              | TRY block_statement finally
              | TRY block_statement catches finally

catches : catch_clause
        | catches catch_clause

catch_clause : CATCH OPEN_PAREN argument_declaration CLOSE_PAREN block_statement

finally : FINALLY block_statement

break_statement : BREAK
                | BREAK identifier

continue_statement : CONTINUE
                   | CONTINUE identifier

statement : simple_statement
          | if_then_statement
          | if_then_else_statement
          | labelled_statement
          | switch_statement

within_for_statement : very_simple_statement END_STATEMENT
                     | local_declaration
                     | END_STATEMENT

very_simple_statement : assignment_statement
                      | method_call_statement

simple_statement : very_simple_statement END_STATEMENT
                 | block_statement
                 | throw_statement
                 | return_statement
                 | try_statement
                 | break_statement END_STATEMENT
                 | continue_statement END_STATEMENT
                 | empty_statement

assignment_statement : assignment

statement_inner : simple_statement
                | if_then_else_statement_inner
                | while_statement_inner

local_declaration : untyped_declaration
                  | field_declaration

untyped_declaration : VARIABLE identifier_list END_STATEMENT

within_block_statement : local_declaration
                       | pragma
                       | statement

left_value : name
           | pointer_access
           | field_access
           | vector_access

assignment : left_value ASSIGN expression

expression_list : expression
                | expression_list COMMA expression

block_statement : START_BLOCK END_BLOCK
                | START_BLOCK block_statement_list END_BLOCK

block_statement_list : within_block_statement
                     | block_statement_list within_block_statement

class_qualifier : CLASS OPEN_GENERIC type CLOSE_GENERIC

field_access : primary DOT identifier
             | SUPER DOT identifier
             | generic_type DOT identifier

generic_type : type OPEN_GENERIC type_list CLOSE_GENERIC

method_call : name OPEN_PAREN CLOSE_PAREN
            | name OPEN_PAREN expression_list CLOSE_PAREN
            | primary DOT identifier OPEN_PAREN CLOSE_PAREN
            | primary DOT identifier OPEN_PAREN expression_list CLOSE_PAREN
            | generic_type DOT identifier OPEN_PAREN CLOSE_PAREN
            | generic_type DOT identifier OPEN_PAREN expression_list CLOSE_PAREN
            | SUPER DOT identifier OPEN_PAREN CLOSE_PAREN
            | SUPER DOT identifier OPEN_PAREN expression_list CLOSE_PAREN
            | NATIVE DOT identifier OPEN_PAREN CLOSE_PAREN
            | NATIVE DOT identifier OPEN_PAREN expression_list CLOSE_PAREN

name : simple_name
     | qualified_name

simple_name : identifier

qualified_name : name DOT identifier

unary_expression : thing
                 | SUB unary_expression

thing : primary
      | name

literal : constant_null
        | constant_integer
        | constant_string
        | constant_cstring
        | constant_char
        | constant_double
        | constant_boolean

primary : literal
        | THIS
        | vector_list
        | OPEN_PAREN expression CLOSE_PAREN
        | cast
        | new
        | field_access
        | method_call
        | vector_access
        | pointer_access
        | class_qualifier

vector_list : type START_BLOCK expression_list END_BLOCK
            | type START_BLOCK expression_list COMMA END_BLOCK
            | START_BLOCK expression_list END_BLOCK
            | START_BLOCK expression_list COMMA END_BLOCK

pointer_access : OPEN_SQUARE expression CLOSE_SQUARE

vector_access : name OPEN_SQUARE expression CLOSE_SQUARE
              | primary OPEN_SQUARE expression CLOSE_SQUARE

cast : CAST type OPEN_PAREN expression CLOSE_PAREN

cast : CAST type OPEN_PAREN expression CLOSE_PAREN

new : NEW type OPEN_SQUARE expression CLOSE_SQUARE
    | NEW type OPEN_PAREN expression_list CLOSE_PAREN
    | NEW type OPEN_PAREN CLOSE_PAREN

identifier : IDENTIFIER

constant_null : CONST_NULL

constant_integer : CONST_INT

constant_string : CONST_STRING

constant_cstring : CONST_CSTRING

constant_char : CONST_CHAR

constant_double : CONST_DOUBLE

constant_boolean : CONST_TRUE
                 | CONST_FALSE

type : name
     | base_type
     | complex_type

complex_type : type ARRAY_DEF
             | type POINTER
             | type REFERENCE
             | generic_type
             | type OPEN_GENERIC CLOSE_GENERIC

type_list : type
          | type_list COMMA type

base_type : INT
          | LONG
          | WORD
          | BOOL
          | CHAR
          | BYTE
          | VOID

</pre>
<%include("/footer.lsi");%>