
Nonterminals
    program tl_exprs tl_expr.

Terminals
    boolean.

Rootsymbol
    program.

program -> tl_exprs : '$1'.

tl_exprs -> tl_expr : ['$1'].
tl_exprs -> tl_expr tl_exprs : ['$1'|'$2'].

tl_expr -> boolean : '$1'.
