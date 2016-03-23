
Definitions.

Number = [0-9]
Float  = [0-9]+\.[0-9]+([eE][-+]?[0-9]+)?
Bool = (true|false)

Endls       = (\s|\t)*(\r?\n)
Whites      = \s+
Tabs        = \t+

Add         = (\+|-)

Rules.

{Bool} : make_token(boolean, TokenLine, TokenChars).
{Number}+ : make_token(integer, TokenLine, TokenChars, fun erlang:list_to_integer/1).
{Float}   : make_token(float,   TokenLine, TokenChars, fun erlang:list_to_float/1).

{Add} : make_token(add_op, TokenLine, TokenChars).

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
