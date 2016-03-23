
Nonterminals
    program tl_exprs tl_expr
    add mul
    unary
    literal.

Terminals
    add_op mul_op
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

add -> add add_op mul : {op, line('$2'), unwrap('$2'), '$1', '$3'}.
add -> mul : '$1'.

mul -> mul mul_op unary : {op, line('$2'), to_erl_op(unwrap('$2')), '$1', '$3'}.
mul -> unary : '$1'.

unary -> add_op literal : {op, line('$1'), unwrap('$1'), '$2'}.
unary -> literal : '$1'.

literal -> boolean : {atom, line('$1'), unwrap('$1')}.
literal -> integer: '$1'.
literal -> float: '$1'.

Erlang code.

unwrap({_,V})   -> V;
unwrap({_,_,V}) -> V.

line(T) when is_tuple(T) -> element(2, T);
line([H|_T]) -> element(2, H).

to_erl_op('%') -> 'rem';
to_erl_op('//') -> 'div';
to_erl_op(Op) -> Op.
