%% Cloud Stack Lang parser file.
%%
%% Copyright (C) MARTINEAU Emeric 2020
%%

Nonterminals
  root
  assignment assignments
  map_arg map_args
  expr
  exprs
  map
  array
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

root -> assignments : '$1'.

assignments -> assignment : '$1'.
assignments -> assignment assignments : lists:merge('$1', '$2').

assignment -> name '=' expr : [{assign, '$1', '$3'}].

map_args -> map_arg : '$1'.
map_args -> map_arg map_args : lists:merge('$1', '$2').

map_arg -> name '=' expr : [{map_arg, '$1', '$3'}].

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

expr -> expr '+' expr : {add_op, '$1', '$3'}.
expr -> expr '-' expr : {sub_op, '$1', '$3'}.
expr -> expr '*' expr : {mul_op, '$1', '$3'}.
expr -> expr '/' expr : {div_op, '$1', '$3'}.
expr -> expr '^' expr : {exp_op, '$1', '$3'}.

exprs -> expr : ['$1'].
exprs -> expr exprs : lists:merge(['$1'], '$2').

map -> open_map close_map : {build_empty_map, '$1'}.
map -> open_map map_args close_map : {build_map, '$1', '$2'}.

array -> open_array close_array : {build_empty_array, '$1'}.
array -> open_array exprs close_array : {build_array, '$1', '$2'}.

%function_call -> open_parenthesis close_parenthesis : {fct_call_empty, '$1'}.

Erlang code.
