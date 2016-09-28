
Nonterminals
    program tl_exprs tl_expr
    add mul
    concat
    unary
    comp
    bool_or_op
    bool_and_op
    match
    literal
    list tuple map
    list_items seq_items map_item map_items
    map_update
    fn_call.

Terminals
    add_op mul_op
    comp_op
    bool_and bool_or
    bool_not
    float integer boolean string bstring
    assign var
    atom
    open close
    open_list close_list
    open_map close_map
    cons_op
    sep
    concat_op
    dot
    colon
    hash
    nl.

Rootsymbol
    program.

program -> nl tl_exprs : '$2'.
program -> tl_exprs : '$1'.

tl_exprs -> tl_expr : ['$1'].
tl_exprs -> tl_expr nl: ['$1'].
tl_exprs -> tl_expr nl tl_exprs : ['$1'|'$3'].

tl_expr -> match : '$1'.

match -> bool_or_op assign bool_or_op : {match, line('$1'), '$1', '$3'}.
match -> bool_or_op : '$1'.

bool_or_op -> bool_and_op bool_or bool_or_op :
    {op, line('$2'), to_erl_op(unwrap('$2')), '$1', '$3'}.
bool_or_op -> bool_and_op : '$1'.

bool_and_op -> comp bool_and bool_and_op :
    {op, line('$2'), to_erl_op(unwrap('$2')), '$1', '$3'}.
bool_and_op -> comp : '$1'.

comp -> concat  comp_op comp : {op, line('$2'), to_erl_op(unwrap('$2')), '$1', '$3'}.
comp -> concat : '$1'.

concat -> add concat_op concat :
    {op, line('$2'), to_erl_op(unwrap('$2')), '$1', '$3'}.
concat -> add : '$1'.

add -> add add_op mul : {op, line('$2'), unwrap('$2'), '$1', '$3'}.
add -> mul : '$1'.

mul -> mul mul_op unary : {op, line('$2'), to_erl_op(unwrap('$2')), '$1', '$3'}.
mul -> unary : '$1'.

unary -> add_op literal : {op, line('$1'), unwrap('$1'), '$2'}.
unary -> bool_not literal : {op, line('$1'), unwrap('$1'), '$2'}.
unary -> literal : '$1'.

literal -> boolean : {atom, line('$1'), unwrap('$1')}.
literal -> integer: '$1'.
literal -> float: '$1'.
literal -> string : '$1'.
literal -> bstring :
    Line = line('$1'),
    {bin, Line, [{bin_element, Line, {string, Line, unwrap('$1')},
                     default, default}]}.
literal -> var : '$1'.
literal -> atom : '$1'.
literal -> open bool_or_op close : '$2'.
literal -> list : '$1'.
literal -> tuple : '$1'.
literal -> map : '$1'.
literal -> map_update : '$1'.
literal -> fn_call : '$1'.

list -> open_list close_list : {nil, line('$1')}.
list -> open_list list_items close_list : '$2'.

map -> open_map close_map : {map, line('$1'), []}.
map -> open_map map_items close_map : {map, line('$1'), '$2'}.

map_item -> literal colon literal : {map_field_assoc, line('$1'), '$1', '$3'}.

map_items -> map_item : ['$1'].
map_items -> map_item sep : ['$1'].
map_items -> map_item sep map_items: ['$1'|'$3'].

map_update -> literal hash map : {map, line('$1'), '$1', unwrap('$3')}.

list_items -> literal : {cons, line('$1'), '$1', {nil, line('$1')}}.
list_items -> literal sep : {cons, line('$1'), '$1', {nil, line('$1')}}.
list_items -> literal sep list_items : {cons, line('$1'), '$1', '$3'}.
list_items -> literal cons_op literal : {cons, line('$1'), '$1', '$3'}.

tuple -> open close : {tuple, line('$1'), []}.
tuple -> open literal sep close : {tuple, line('$1'), ['$2']}.
tuple -> open literal sep seq_items close : {tuple, line('$1'), ['$2'|'$4']}.

seq_items -> literal : ['$1'].
seq_items -> literal sep : ['$1'].
seq_items -> literal sep seq_items : ['$1'|'$3'].

fn_call -> atom open literal close : {call, line('$1'), '$1', ['$3']}.
fn_call -> atom tuple : {call, line('$1'), '$1', unwrap('$2')}.

fn_call -> atom dot atom open literal close :
    {call, line('$1'), {remote, line('$1'), '$1', '$3'}, ['$5']}.
fn_call -> atom dot atom tuple :
    {call, line('$1'), {remote, line('$1'), '$1', '$3'}, unwrap('$4')}.

Erlang code.

unwrap({_,V})   -> V;
unwrap({_,_,V}) -> V.

line(T) when is_tuple(T) -> element(2, T);
line([H|_T]) -> element(2, H).

to_erl_op('+') -> '+';
to_erl_op('-') -> '-';
to_erl_op('*') -> '*';
to_erl_op('/') -> '/';
to_erl_op('//') -> 'div';
to_erl_op('%') -> 'rem';
to_erl_op('|') -> 'bor';
to_erl_op('&') -> 'band';
to_erl_op('^') -> 'bxor';
to_erl_op('>>') -> 'bsr';
to_erl_op('<<') -> 'bsl';
to_erl_op('~') -> 'bnot';
to_erl_op('and') -> 'andalso';
to_erl_op('andd') -> 'and';
to_erl_op('or') -> 'orelse';
to_erl_op('orr') -> 'or';
to_erl_op('xor') -> 'xor';
to_erl_op('!') -> '!';
to_erl_op('not') -> 'not';
to_erl_op('++') -> '++';
to_erl_op('--') -> '--';
to_erl_op('<') -> '<';
to_erl_op('<=') -> '=<';
to_erl_op('>') -> '>';
to_erl_op('>=') -> '>=';
to_erl_op('==') -> '==';
to_erl_op('is') -> '=:=';
to_erl_op('!=') -> '/=';
to_erl_op('isnt') -> '=/='.
