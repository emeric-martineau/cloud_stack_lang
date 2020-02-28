%% Cloud Stack Lang parser file.
%%
%% Copyright (C) MARTINEAU Emeric 2020
%%

Nonterminals
  root
  assignment
  assignments
  expr
  exprs
  map
  array
.

Terminals
  int
  atom
  float
  name
  simple_string interpolate_string
  '+'
  '-'
  '*'
  '/'
  '='
  open_map close_map
  open_array close_array
.

Rootsymbol
   root
.

Right 100 '='.
Left 300 '+'.
Left 300 '-'.
Left 400 '*'.
Left 400 '/'.

root -> assignments : '$1'.

assignments -> assignment : '$1'.
assignments -> assignment assignments : lists:merge('$1', '$2').

assignment -> name '=' expr : [{assign, '$1', '$3'}].

expr -> int : unwrap('$1').
expr -> atom : unwrap('$1').
expr -> float : unwrap('$1').
expr -> name : '$1'.
expr -> simple_string : '$1'.
expr -> interpolate_string : '$1'.
expr -> map : '$1'.
expr -> array : '$1'.

expr -> expr '+' expr : {add_op, '$1', '$3'}.
expr -> expr '-' expr : {sub_op, '$1', '$3'}.
expr -> expr '*' expr : {mul_op, '$1', '$3'}.
expr -> expr '/' expr : {div_op, '$1', '$3'}.

exprs -> expr : ['$1'].
exprs -> expr exprs : lists:merge(['$1'], '$2').

map -> open_map close_map : build_empty_map('$1').
map -> open_map assignments close_map : build_map('$1', '$2').

array -> open_array close_array : build_empty_array('$1').
array -> open_array exprs close_array : build_array('$1', '$2').

Erlang code.

unwrap({int, Line, Value}) ->
  {int, Line, list_to_integer(Value)};
unwrap({atom, Line, Value}) ->
  {atom, Line, Value};
unwrap({float, Line, Value}) ->
  {float, Line, list_to_float(Value)}.

build_empty_map({open_map, Line}) ->
  {map, Line, #{}}.

build_map(Open_Map, Map) ->
  {open_map, Line} = Open_Map,
  {map, Line, Map}.

build_empty_array({open_array, Line}) ->
  {array, Line, []}.

build_array(Open_Array, Array) ->
  {open_array, Line} = Open_Array,
  {array, Line, Array}.