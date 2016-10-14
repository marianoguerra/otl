
Nonterminals
    program tl_exprs tl_expr
    add mul
    concat
    unary
    comp
    bool_or_op
    bool_and_op
    e_match
    literal
    list tuple map
    list_items seq_items map_item map_items
    map_update
    e_when e_when_clause e_when_clauses
    e_case e_case_clause e_case_clauses
    e_fn e_fn_clause e_fn_clauses
    fn_lambda
    body
    mod_exprs mod_expr
    e_try catch_clauses catch_clause
    e_begin
    e_receive
    e_lc qualifiers qualifier
    guard_seq guard
    fn_call fn_ref.

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
    scolon
    concat_op
    dot
    colon
    hash
    when
    match
    fn
    end
    try catch after
    do
    for in
    receive
    nl.

Rootsymbol
    program.

program -> nl mod_exprs : '$2'.
program -> mod_exprs : '$1'.

mod_exprs -> mod_expr : ['$1'].
mod_exprs -> mod_expr nl : ['$1'].
mod_exprs -> mod_expr nl mod_exprs : ['$1'|'$3'].

mod_expr -> e_fn : '$1'.

e_fn -> fn atom colon e_fn_clauses end :
    Clauses = '$4',
    [Clause|_] = Clauses,
    {_, _, Args, _, _} = Clause,
    Arity = length(Args),
    {function, line('$1'), unwrap('$2'), Arity, Clauses}.

e_fn_clauses -> e_fn_clause : ['$1'].
e_fn_clauses -> e_fn_clause e_fn_clauses : ['$1'|'$2'].

e_fn_clause -> tuple body : {clause, line('$1'), unwrap('$1'), [], '$2'}.
e_fn_clause -> tuple when guard_seq body :
    {clause, line('$1'), unwrap('$1'), '$3', '$4'}.
e_fn_clause -> open literal close body : {clause, line('$1'), ['$2'], [], '$4'}.
e_fn_clause -> open literal close when guard_seq body :
    {clause, line('$1'), ['$2'], '$5', '$6'}.

tl_exprs -> tl_expr : ['$1'].
tl_exprs -> tl_expr nl: ['$1'].
tl_exprs -> tl_expr nl tl_exprs : ['$1'|'$3'].

tl_expr -> e_when : '$1'.
tl_expr -> e_case : '$1'.
tl_expr -> e_try : '$1'.
tl_expr -> e_begin : '$1'.
tl_expr -> e_receive : '$1'.
tl_expr -> e_lc : '$1'.
tl_expr -> e_match : '$1'.

e_match -> bool_or_op assign bool_or_op : {match, line('$1'), '$1', '$3'}.
e_match -> bool_or_op : '$1'.

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
literal -> fn_ref : '$1'.
literal -> fn_lambda : '$1'.

list -> open_list close_list : {nil, line('$1')}.
list -> open_list list_items close_list : '$2'.

map -> open_map close_map : {map, line('$1'), []}.
map -> open_map map_items close_map : {map, line('$1'), '$2'}.

map_item -> literal colon literal : {map_field_assoc, line('$1'), '$1', '$3'}.
map_item -> literal assign literal : {map_field_exact, line('$1'), '$1', '$3'}.

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

fn_ref -> fn dot atom dot atom open literal close :
    {'fun', line('$1'), {function, '$3', '$5', '$7'}}.
fn_ref -> fn dot atom dot var open literal close :
    {'fun', line('$1'), {function, '$3', '$5', '$7'}}.
fn_ref -> fn dot var dot var open literal close :
    {'fun', line('$1'), {function, '$3', '$5', '$7'}}.
fn_ref -> fn dot var dot atom open literal close :
    {'fun', line('$1'), {function, '$3', '$5', '$7'}}.

fn_lambda -> fn colon e_fn_clauses end : {'fun', line('$1'), {clauses, '$3'}}.

e_when -> when e_when_clauses end : {'if', line('$1'), '$2'}.

e_when_clause -> guard_seq body :
    {clause, line('$1'), [], '$1', '$2'}.

e_when_clauses -> e_when_clause : ['$1'].
e_when_clauses -> e_when_clause e_when_clauses : ['$1'|'$2'].

guard_seq -> guard : ['$1'].
guard_seq -> guard scolon guard_seq : ['$1'|'$3'].

guard -> bool_or_op : ['$1'].
guard -> bool_or_op sep guard : ['$1'|'$3'].

e_case -> match bool_or_op colon e_case_clauses end :
    {'case', line('$1'), '$2', '$4'}.

e_case_clause -> literal body : {clause, line('$1'), ['$1'], [], '$2'}.
e_case_clause -> literal when guard_seq body :
    {clause, line('$1'), ['$1'], '$3', '$4'}.

e_case_clauses -> e_case_clause : ['$1'].
e_case_clauses -> e_case_clause e_case_clauses : ['$1'|'$2'].

e_try -> try colon tl_exprs after colon tl_exprs end :
    {'try', line('$1'), '$3', [], [], '$6'}.
e_try -> try colon tl_exprs catch colon catch_clauses after colon tl_exprs end :
    {'try', line('$1'), '$3', [], '$6', '$9'}.
e_try -> try colon tl_exprs catch colon catch_clauses end :
    {'try', line('$1'), '$3', [], '$6', []}.

catch_clauses -> catch_clause : ['$1'].
catch_clauses -> catch_clause catch_clauses : ['$1'|'$2'].

catch_clause -> literal body :
    Line = line('$1'),
    {clause, Line, [{tuple, Line,
                        [{atom, Line, throw}, '$1', {var, Line, '_'}]}],
                        [], '$2'}.

catch_clause -> atom sep literal body :
    Line = line('$1'),
    {clause, Line, [{tuple, Line, ['$1', '$3', {var, Line, '_'}]}], [], '$4'}.

e_begin -> do colon tl_exprs end : {block, line('$1'), '$3'}.

e_receive -> receive colon e_case_clauses end : {'receive', line('$1'), '$3'}.
e_receive -> receive colon e_case_clauses after literal colon tl_exprs end :
    {'receive', line('$1'), '$3', '$5', '$7'}.

e_lc -> for qualifiers colon tl_exprs end :
    Exprs = '$4',
    case Exprs of
        [Expr] -> {lc, line('$1'), Expr, '$2'};
        _ -> {lc, line('$1'), {block, line(Exprs), Exprs}, '$2'}
    end.

qualifiers -> qualifier : ['$1'].
qualifiers -> qualifier sep qualifiers : ['$1'|'$3'].

qualifier -> literal in literal : {generate, line('$1'), '$1', '$3'}.
qualifier -> bool_or_op : '$1'.

body -> open_map tl_exprs close_map : '$2'.

Erlang code.

unwrap({_,V})   -> V;
unwrap({_,_,V}) -> V.

line(T) when is_tuple(T) -> element(2, T);
line([H|_T]) -> line(H).

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
