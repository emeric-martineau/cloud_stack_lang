%% Cloud Stack Lang parser file.
%%
%% Copyright (C) MARTINEAU Emeric 2020
%%

Nonterminals
  root
  assignment
  expr exprs
  map map_arg map_args map_access
  array
  function_call
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
  open_map close_map
  open_array close_array
  open_parenthesis close_parenthesis
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

root -> assignment : ['$1'].
root -> function_call : ['$1'].
root -> assignment root : lists:append(['$1'], '$2').
root -> function_call root : lists:append(['$1'], '$2').


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

function_call -> name open_parenthesis close_parenthesis : {fct_call, '$1', []}.
function_call -> name open_parenthesis exprs close_parenthesis : {fct_call, '$1', '$3'}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Erlang code.
