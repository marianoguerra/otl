
Nonterminals
    program tl_exprs tl_expr
    add
    literal.

Terminals
    add_op
    float integer boolean
    nl.

Rootsymbol
    program.

program -> nl tl_exprs : '$2'.
program -> tl_exprs : '$1'.

tl_exprs -> tl_expr : ['$1'].
tl_exprs -> tl_expr nl: ['$1'].
tl_exprs -> tl_expr nl tl_exprs : ['$1'|'$3'].

tl_expr -> add : '$1'.

add -> add add_op literal : {op, line('$2'), unwrap('$2'), '$1', '$3'}.
add -> literal : '$1'.

literal -> boolean : {atom, line('$1'), unwrap('$1')}.
literal -> integer: '$1'.
literal -> float: '$1'.

Erlang code.

unwrap({_,V})   -> V;
unwrap({_,_,V}) -> V.

line(T) when is_tuple(T) -> element(2, T);
line([H|_T]) -> element(2, H).
