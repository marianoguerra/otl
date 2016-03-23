
Nonterminals
    program tl_exprs tl_expr.

Terminals
    float integer boolean.

Rootsymbol
    program.

program -> tl_exprs : '$1'.

tl_exprs -> tl_expr : ['$1'].
tl_exprs -> tl_expr tl_exprs : ['$1'|'$2'].

tl_expr -> boolean : {atom, line('$1'), unwrap('$1')}.
tl_expr -> integer: '$1'.
tl_expr -> float: '$1'.

Erlang code.

unwrap({_,V})   -> V;
unwrap({_,_,V}) -> V.

line(T) when is_tuple(T) -> element(2, T);
line([H|_T]) -> element(2, H).
