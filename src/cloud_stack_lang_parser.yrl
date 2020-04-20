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

Nonterminals
  root
  assignment
  expr exprs
  map map_arg map_args map_access
  array
  function_call function_namespace
  module module_map module_map_arg module_map_args module_namespace
.

Terminals
  int
  hexa
  octal
  atom
  float
  name
  simple_string interpolate_string
  '+'
  '-'
  '*'
  '/'
  '='
  '^'
  '.'
  open_map close_map
  open_array close_array
  open_parenthesis close_parenthesis
  namespace_separator
.

Rootsymbol
   root
.

Right 100 '='.
Left 300 '+'.
Left 300 '-'.
Left 400 '*'.
Left 400 '/'.
Left 500 '^'.
Nonassoc 900 open_array close_array '.' open_parenthesis close_parenthesis.

root -> assignment : ['$1'].
root -> function_call : ['$1'].
root -> module : ['$1'].
root -> assignment root : lists:append(['$1'], '$2').
root -> function_call root : lists:append(['$1'], '$2').
root -> module root : lists:append(['$1'], '$2').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assignment

assignment -> name '=' expr : {assign, '$1', '$3'}.
%assignment -> name open_array close_array '=' expr: {map_push, '$1', $5}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Expression

expr -> int : '$1'.
expr -> atom : '$1'.
expr -> float : '$1'.
expr -> hexa : '$1'.
expr -> octal : '$1'.
expr -> name : '$1'.
expr -> simple_string : '$1'.
expr -> interpolate_string : '$1'.
expr -> map : '$1'.
expr -> array : '$1'.
expr -> open_parenthesis expr close_parenthesis : {parenthesis, '$2'}.
expr -> function_call : '$1'.

expr -> expr '+' expr : {add_op, '$1', '$3'}.
expr -> expr '-' expr : {sub_op, '$1', '$3'}.
expr -> expr '*' expr : {mul_op, '$1', '$3'}.
expr -> expr '/' expr : {div_op, '$1', '$3'}.
expr -> expr '^' expr : {exp_op, '$1', '$3'}.
expr -> name map_access : {map_get, '$1', '$2'}.

exprs -> expr : ['$1'].
exprs -> expr exprs : lists:append(['$1'], '$2').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Map

map -> open_map close_map : {build_empty_map, '$1'}.
map -> open_map map_args close_map : {build_map, '$1', '$2'}.

map_args -> map_arg : '$1'.
map_args -> map_arg map_args : lists:append('$1', '$2').

map_arg -> atom '=' expr : [{map_arg, '$1', '$3'}].
map_arg -> name '=' expr : [{map_arg, '$1', '$3'}].
map_arg -> simple_string '=' expr : [{map_arg, '$1', '$3'}].
map_arg -> interpolate_string '=' expr : [{map_arg, '$1', '$3'}].

% Map access
map_access -> open_array expr close_array : ['$2'].
map_access -> map_access open_array expr close_array : lists:append('$1', ['$3']).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Array

array -> open_array close_array : {build_empty_array, '$1'}.
array -> open_array exprs close_array : {build_array, '$1', '$2'}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function

function_call -> function_namespace open_parenthesis close_parenthesis : {fct_call, '$1', []}.
function_call -> function_namespace open_parenthesis exprs close_parenthesis : {fct_call, '$1', '$3'}.
function_call -> name open_parenthesis close_parenthesis : {fct_call, ['$1'], []}.
function_call -> name open_parenthesis exprs close_parenthesis : {fct_call, ['$1'], '$3'}.

function_namespace -> name '.' name : lists:append(['$1'], ['$3']).
function_namespace -> function_namespace '.' name : lists:append('$1', ['$3']).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Module

module_map -> open_map module_map_args close_map : {build_module_map, '$1', '$2'}.

module_map_args -> module_map_arg : '$1'.
module_map_args -> module_map_arg module_map_args : lists:append('$1', '$2').

module_map_arg -> name '=' expr : [{module_map_arg, '$1', '$3'}].

module_namespace -> name namespace_separator name : lists:append(['$1'], ['$3']).
module_namespace -> module_namespace namespace_separator name : lists:append('$1', ['$3']).

module -> module_namespace open_parenthesis atom close_parenthesis module_map : {module, '$1', '$3', '$5'}.
module -> module_namespace open_parenthesis atom map close_parenthesis : {module, '$1', '$3', '$4'}.
module -> module_namespace open_parenthesis atom name close_parenthesis : {module, '$1', '$3', '$4'}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Erlang code.
