
Definitions.

Bool = true

Endls       = (\s|\t)*(\r?\n)
Whites      = \s+
Tabs        = \t+

Rules.

{Bool} : make_token(boolean, TokenLine, TokenChars).

% spaces, tabs and new lines
{Endls}                 : skip_token.
{Whites}                : skip_token.
{Tabs}                  : skip_token.

Erlang code.

make_token(Name, Line, Chars) when is_list(Chars) ->
    {token, {Name, Line, list_to_atom(Chars)}};
make_token(Name, Line, Chars) ->
    {token, {Name, Line, Chars}}.
