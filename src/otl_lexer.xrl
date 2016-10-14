
Definitions.

Number = [0-9]
Float  = [0-9]+\.[0-9]+([eE][-+]?[0-9]+)?
Bool = (true|false)

Endls       = (\s|\t)*(\r?\n)
Whites      = \s+
Tabs        = \t+

Add         = (\+|-)
Mul         = (\*|//|/|%)

Comp        = (<|<=|==|is|>=|>|!=|isnt)

BoolAnd     = and
BoolOr      = or

BoolNot     = not

Assign      = =

Identifier  = [A-Z\_][a-zA-Z0-9\_]*
Atom        = [a-z][a-zA-Z0-9\_@]*

Open        = \(
Close       = \)

OpenList    = \[
CloseList   = \]

OpenMap     = \{
CloseMap    = \}

ConsOp      = ::
Sep         = ,
SColon      = ;
Dot         = \.
Colon       = :
Hash        = #
Concat      = (\+\+|--)

String      = "(\\\^.|\\.|[^\"])*"
BString     = '(\\\^.|\\.|[^\'])*'
AtomString  = `(\\\^.|\\.|[^\`])*`

Rules.

{Bool} : make_token(boolean, TokenLine, TokenChars).
{Number}+ : make_token(integer, TokenLine, TokenChars, fun erlang:list_to_integer/1).
{Float}   : make_token(float,   TokenLine, TokenChars, fun erlang:list_to_float/1).

{Add} : make_token(add_op, TokenLine, TokenChars).
{Mul} : make_token(mul_op, TokenLine, TokenChars).

{Assign} : make_token(assign, TokenLine, TokenChars).

{Comp} : make_token(comp_op, TokenLine, TokenChars).

{BoolAnd}                : make_token(bool_and, TokenLine, TokenChars).
{BoolOr}                 : make_token(bool_or,  TokenLine, TokenChars).

{BoolNot}                : make_token(bool_not, TokenLine, TokenChars).

{Identifier} : make_token(var, TokenLine, TokenChars).
{Atom}                   : {token, atom_or_identifier(TokenChars, TokenLine)}.

{Open} : make_token(open, TokenLine, TokenChars).
{Close} : make_token(close, TokenLine, TokenChars).

{OpenList}               : make_token(open_list,   TokenLine, TokenChars).
{CloseList}              : make_token(close_list,  TokenLine, TokenChars).

{OpenMap}                : make_token(open_map,    TokenLine, TokenChars).
{CloseMap}               : make_token(close_map ,  TokenLine, TokenChars).

{ConsOp}                 : make_token(cons_op, TokenLine, TokenChars).
{Sep}                    : make_token(sep,     TokenLine, TokenChars).
{SColon}                 : make_token(scolon,     TokenLine, TokenChars).
{Dot}                    : make_token(dot,     TokenLine, TokenChars).
{Colon}                  : make_token(colon,   TokenLine, TokenChars).
{Hash}                   : make_token(hash,    TokenLine, TokenChars).

{Concat}                 : make_token(concat_op, TokenLine, TokenChars).

{String}                 : build_string(string, TokenChars, TokenLine, TokenLen).
{BString}                : build_string(bstring, TokenChars, TokenLine, TokenLen).

{AtomString}             : build_atom_string(TokenChars, TokenLine, TokenLen).

% spaces, tabs and new lines
{Endls}+                 : make_token(nl, TokenLine, endls(TokenChars)).

{Whites}                : skip_token.
{Tabs}                  : skip_token.

Erlang code.

make_token(Name, Line, Chars) when is_list(Chars) ->
    {token, {Name, Line, list_to_atom(Chars)}};
make_token(Name, Line, Chars) ->
    {token, {Name, Line, Chars}}.

make_token(Name, Line, Chars, Fun) ->
    {token, {Name, Line, Fun(Chars)}}.

endls(Chars) ->
    lists:filter(fun (C) -> C == $\n end, Chars).

build_atom_string(Chars, Line, Len) ->
  String = unescape_string(lists:sublist(Chars, 2, Len - 2), Line),
  {token, {atom, Line, list_to_atom(String)}}.

build_string(Type, Chars, Line, Len) ->
  String = unescape_string(lists:sublist(Chars, 2, Len - 2), Line),
    {token, {Type, Line, String}}.

unescape_string(String, Line) -> unescape_string(String, Line, []).

unescape_string([], _Line, Output) ->
  lists:reverse(Output);
unescape_string([$\\, Escaped | Rest], Line, Output) ->
  Char = map_escaped_char(Escaped, Line),
  unescape_string(Rest, Line, [Char|Output]);
unescape_string([Char|Rest], Line, Output) ->
  unescape_string(Rest, Line, [Char|Output]).

map_escaped_char(Escaped, Line) ->
  case Escaped of
    $\\ -> $\\;
    $/ -> $/;
    $\" -> $\";
    $\' -> $\';
    $\( -> $(;
    $b -> $\b;
    $d -> $\d;
    $e -> $\e;
    $f -> $\f;
    $n -> $\n;
    $r -> $\r;
    $s -> $\s;
    $t -> $\t;
    $v -> $\v;
    _ -> throw({error, {Line, fn_lexer, ["unrecognized escape sequence: ", [$\\, Escaped]]}})
  end.

atom_or_identifier(String, TokenLine) ->
     case is_reserved(String) of
         true ->
            {list_to_atom(String), TokenLine};
         false ->
            {atom, TokenLine, build_atom(String, TokenLine)}
     end.

build_atom(Atom, _Line) -> list_to_atom(Atom).

is_reserved("fn")    -> true;
is_reserved("when")    -> true;
is_reserved("else")    -> true;
is_reserved("try")    -> true;
is_reserved("catch")    -> true;
is_reserved("after")    -> true;
is_reserved("match")    -> true;
is_reserved("do")    -> true;
is_reserved("receive")    -> true;
is_reserved("end")    -> true;
is_reserved(_)         -> false.
