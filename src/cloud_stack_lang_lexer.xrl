%%
%% Copyright 2020 Cloud Stack Lang Contributors
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%

Definitions.

INT                       = -?([0-9]+|[0-9][0-9_]+[0-9])
FLOAT                     = -?([0-9]+|[0-9][0-9_]+[0-9])\.([0-9]+|[0-9][0-9_]+[0-9])((E|e)(\+|-)?([0-9]+|[0-9][0-9_]+[0-9]))?
HEXA                      = 0[xX][a-fA-F0-9]+
OCTAL                     = 0[oO][0-7]+
ATOM                      = :[a-zA-Z_][a-zA-Z0-9_]*
NAMESPACE_SEPARATOR       = ::
NAME                      = [a-zA-Z_][a-zA-Z0-9_]*
WHITESPACE                = [\s\t\n\r]
SIMPLE_STRING             = '([^'\\]|\\.)*'
INTERPOLATE_STRING        = "([^"\\]|\\.)*"
COMMENT                   = //[^\r|\n]*
%COMMENT_MULTI_LINE        = /*(?:(?!*/).)+*/
DIV                       = /[^/*]
OPEN_MAP                  = \{
CLOSE_MAP                 = \}
OPEN_PARENTHESIS          = \(
CLOSE_PARENTHESIS         = \)
OPEN_ARRAY                = \[
CLOSE_ARRAY               = \]

%% The Rule section defines what to return for each token. Typically you'd
%% want the TokenLine and the TokenChars to capture the matched
%% expression.

Rules.

{COMMENT}                   : skip_token.
%{COMMENT_MULTI_LINE}        : skip_token.
\+                          : {token, {'+', TokenLine}}.
\-                          : {token, {'-', TokenLine}}.
\*                          : {token, {'*', TokenLine}}.
{DIV}                       : {token, {'/', TokenLine}}.
\=                          : {token, {'=', TokenLine}}.
\^                          : {token, {'^', TokenLine}}.
\.                          : {token, {'.', TokenLine}}.
{ATOM}                      : {token, {atom, TokenLine, TokenChars}}.
{NAME}                      : {token, {name, TokenLine, TokenChars}}.
{INT}                       : {token, {int, TokenLine, TokenChars}}.
{FLOAT}                     : {token, {float, TokenLine, TokenChars}}.
{HEXA}                      : {token, {hexa, TokenLine, TokenChars}}.
{OCTAL}                     : {token, {octal, TokenLine, TokenChars}}.
{SIMPLE_STRING}             : {token, {simple_string, TokenLine, TokenChars}}.
{INTERPOLATE_STRING}        : {token, {interpolate_string, TokenLine, TokenChars}}.
{WHITESPACE}+               : skip_token.
{OPEN_MAP}                  : {token, {open_map, TokenLine}}.
{CLOSE_MAP}                 : {token, {close_map, TokenLine}}.
{OPEN_ARRAY}                : {token, {open_array, TokenLine}}.
{CLOSE_ARRAY}               : {token, {close_array, TokenLine}}.
{OPEN_PARENTHESIS}          : {token, {open_parenthesis, TokenLine}}.
{CLOSE_PARENTHESIS}         : {token, {close_parenthesis, TokenLine}}.
{NAMESPACE_SEPARATOR}       : {token, {namespace_separator, TokenLine}}.

%% The Erlang code section (which is mandatory), is where you can add
%% erlang functions you can call in the Definitions. In this case we
%% have a to_token to create a token for each named variable (this is
%% not good style, but just to show how to use the code section).

Erlang code.