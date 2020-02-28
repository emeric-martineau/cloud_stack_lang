%% Cloud Stack Lang parser file.
%%
%% Copyright (C) MARTINEAU Emeric 2020
%%
%% The Definitions section defines regexps for each token.

Definitions.

INT                       = [1-9][0-9]*
FLOAT                     = [1-9][0-9]*\.[0-9]+
ATOM                      = :[a-zA-Z_][a-zA-Z0-9_]*
NAME                      = [a-zA-Z_][a-zA-Z0-9_]*
WHITESPACE                = [\s\t\n\r]
SIMPLE_STRING             = '([^'\\]|\\.)*'
INTERPOLATE_STRING        = "([^"\\]|\\.)*"
COMMENT                   = //[^\r|\n]*
COMMENT_MULTI_LINE        = /\*(.|[\s\t\n\r])+*\*/
DIV                       = /[^/*]
OPEN_MAP                  = \{
CLOSE_MAP                 = \}
OPEN_ARRAY                = \[
CLOSE_ARRAY               = \]

%% The Rule section defines what to return for each token. Typically you'd
%% want the TokenLine and the TokenChars to capture the matched
%% expression.

Rules.

{COMMENT}                   : skip_token.
{COMMENT_MULTI_LINE}        : skip_token.
\+                          : {token, {'+',  TokenLine}}.
\-                          : {token, {'-',  TokenLine}}.
\*                          : {token, {'*',  TokenLine}}.
{DIV}                       : {token, {'/',  TokenLine}}.
\=                          : {token, {'=',  TokenLine}}.
{ATOM}                      : {token, {atom, TokenLine, to_atom(TokenChars)}}.
{NAME}                      : {token, {name, TokenLine, TokenChars}}.
{INT}                       : {token, {int,  TokenLine, TokenChars}}.
{FLOAT}                     : {token, {float,  TokenLine, TokenChars}}.
{SIMPLE_STRING}             : {token, {simple_string, TokenLine, clear_simple_string(TokenChars)}}.
{INTERPOLATE_STRING}        : {token, {interpolate_string, TokenLine, clear_interpolate_string(TokenChars)}}.
{WHITESPACE}+               : skip_token.
{OPEN_MAP}                  : {token, {open_map,  TokenLine}}.
{CLOSE_MAP}                 : {token, {close_map,  TokenLine}}.
{OPEN_ARRAY}                : {token, {open_array,  TokenLine}}.
{CLOSE_ARRAY}               : {token, {close_array,  TokenLine}}.

%% The Erlang code section (which is mandatory), is where you can add
%% erlang functions you can call in the Definitions. In this case we
%% have a to_token to create a token for each named variable (this is
%% not good style, but just to show how to use the code section).

Erlang code.

%% Given a ":name", chop off : and return name as an atom.
to_atom([$:|Chars]) ->
    list_to_atom(Chars).

clear_simple_string([$'|Chars]) ->
  {L, _} = lists:split(length(Chars) - 1, Chars),
  L.

clear_interpolate_string([$"|Chars]) ->
  {L, _} = lists:split(length(Chars) - 1, Chars),
  L.