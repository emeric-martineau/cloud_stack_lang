defmodule CloudStackLang.Parser do
  @moduledoc ~S"""
  This module parse and run code.

  ## Examples

    iex> CloudStackLang.Parser.parse_and_eval("a = 1")
    %{a: {:int, 1}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1 + 1")
    %{a: {:int, 2}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1 - 1")
    %{a: {:int, 0}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 4 / 2")
    %{a: {:int, 2}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 7\nb = 4\nresult = a + b * 10 / 2")
    %{a: {:int, 7}, b: {:int, 4}, result: {:int, 27}}

    iex> CloudStackLang.Parser.parse_and_eval("a = :toto")
    %{a: {:atom, :toto}}

    iex> CloudStackLang.Parser.parse_and_eval("/*\nThis is multi line comment\n*/\na = :toto")
    %{a: {:atom, :toto}}

    iex> CloudStackLang.Parser.parse_and_eval("// This is single line comment\na = :toto")
    %{a: {:atom, :toto}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1\nb='no interpolate ${a} \\' with single quote'")
    %{a: {:int, 1}, b: {:string, "no interpolate ${a} ' with single quote"}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1\nb=\"interpolate ${a} \\\" with double quote\"")
    %{a: {:int, 1}, b: {:string, "interpolate 1 \" with double quote"}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1.3")
    %{a: {:float, 1.3}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1.3e2")
    %{a: {:float, 1.3e2}}

    iex> CloudStackLang.Parser.parse_and_eval("a = -1.3e2")
    %{a: {:float, -1.3e2}}

    iex> CloudStackLang.Parser.parse_and_eval("a = -1")
    %{a: {:int, -1}}

    iex> CloudStackLang.Parser.parse_and_eval("a = {}")
    %{a: {:map, %{}}}

    iex> CloudStackLang.Parser.parse_and_eval("a = { :a = 2 }")
    %{a: {:map, %{:a => {:int, 2}}}}

    iex> CloudStackLang.Parser.parse_and_eval("a = { :a = 2 'b' = 3}")
    %{a: {:map, %{:a => {:int, 2}, "b" => {:int, 3}}}}

    iex> CloudStackLang.Parser.parse_and_eval("a = []")
    %{a: {:array, []}}

    iex> CloudStackLang.Parser.parse_and_eval("a = [ 2 ]")
    %{a: {:array, [ {:int, 2} ]}}

    iex> CloudStackLang.Parser.parse_and_eval("a = [ 2 3 ]")
    %{a: {:array, [ {:int, 2}, {:int, 3} ]}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 0xfa")
    %{a: {:int, 250}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 0xFA")
    %{a: {:int, 250}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 0o531")
    %{a: {:int, 345}}

    iex> CloudStackLang.Parser.parse_and_eval("a = (1 * (3 + 5))")
    %{a: {:int, 8}}

    iex> CloudStackLang.Parser.parse_and_eval("a = { :a = 1}\nb = a[:a]")
    %{a: {:map, %{ :a => {:int, 1}}}, b: {:int, 1}}

    iex> CloudStackLang.Parser.parse_and_eval("a = { :a = { :b = 2 } }\nb = a[:a][:b]")
    %{a:
      {:map, %{
        :a => {:map, %{
          :b => {:int, 2}
        }}
      }},
    b: {:int, 2}}
  """
  alias CloudStackLang.Operator.Add
  alias CloudStackLang.Operator.Div
  alias CloudStackLang.Operator.Mul
  alias CloudStackLang.Operator.Sub
  alias CloudStackLang.Operator.Exp
  alias CloudStackLang.Number
  alias CloudStackLang.Map, as: MMap

  defp reduce_to_value({:simple_string, _line, value}, _state) do
    s = value
    |> List.to_string
    |> CloudStackLang.String.clear

    {:string, s}
  end

  defp reduce_to_value({:interpolate_string, _line, value}, state) do
    s = value
    |> List.to_string
    |> CloudStackLang.String.interpolate(state)
    |> CloudStackLang.String.clear

    {:string, s}
  end

  defp reduce_to_value({:map, _line, value}, state) do
    m = Enum.map(value,
          fn {:map_arg, key, expr} ->
            {_, k} = reduce_to_value(key, state)
            {k, reduce_to_value(expr, state)}
          end)
        |> Map.new

    {:map, m}
  end

  defp reduce_to_value({:array, _line, value}, state) do
    a = Enum.map(value, fn v -> reduce_to_value(v, state) end)

    {:array, a}
  end

  defp reduce_to_value({:int, _line, value}, _state) do
    # TODO add support xxx_xxx_xxx notation
    {:int, List.to_integer(value)}
  end

  defp reduce_to_value({:float, _line, value}, _state) do
    # TODO add support xxx_xxx_xxx notation
    {:float, List.to_float(value)}
  end

  defp reduce_to_value({:hexa, _line, value}, _state) do
    Number.from_hexa(value)
  end

  defp reduce_to_value({:octal, _line, value}, _state) do
    Number.from_octal(value)
  end

  defp reduce_to_value({:atom, _line, atom_name}, _state) do
    [_ | atom] = atom_name
    {:atom, List.to_atom(atom)}
  end

  defp reduce_to_value({:build_empty_map, _open_map}, _state) do
    {:map, %{}}
  end

  defp reduce_to_value({:build_map, open_map, assignments}, state) do
    {:open_map, line} = open_map
    reduce_to_value({:map, line, assignments}, state)
  end

  defp reduce_to_value({:build_empty_array, _open_map}, _state) do
    {:array, []}
  end

  defp reduce_to_value({:build_array, open_map, assignments}, state) do
    {:open_array, line} = open_map
    reduce_to_value({:array, line, assignments}, state)
  end

  defp reduce_to_value({:name, line, var_name}, state) do
    v_name = List.to_atom(var_name)

    case state[v_name] do
      nil -> {:error, line, "Variable name '#{var_name}' is not declared"}
      v -> v
    end
  end

  defp reduce_to_value({:add_op, lhs, rhs}, state) do
    lvalue = reduce_to_value(lhs, state)
    rvalue = reduce_to_value(rhs, state)

    Add.reduce(lvalue, rvalue)
  end

  defp reduce_to_value({:sub_op, lhs, rhs}, state) do
    lvalue = reduce_to_value(lhs, state)
    rvalue = reduce_to_value(rhs, state)

    Sub.reduce(lvalue, rvalue)
  end

  defp reduce_to_value({:mul_op, lhs, rhs}, state) do
    lvalue = reduce_to_value(lhs, state)
    rvalue = reduce_to_value(rhs, state)

    Mul.reduce(lvalue, rvalue)
  end

  defp reduce_to_value({:div_op, lhs, rhs}, state) do
    lvalue = reduce_to_value(lhs, state)
    rvalue = reduce_to_value(rhs, state)

    Div.reduce(lvalue, rvalue)
  end

  defp reduce_to_value({:exp_op, lhs, rhs}, state) do
    lvalue = reduce_to_value(lhs, state)
    rvalue = reduce_to_value(rhs, state)

    Exp.reduce(lvalue, rvalue)
  end

  defp reduce_to_value({:map_get, var_name, access_key_list}, state) do
    # Get variable value
    local_state = reduce_to_value(var_name, state) # TODO what's happen if not found

    # Parse all arguments
    key_list = Enum.map(access_key_list, fn v ->
      {_, line, _} = v
      {type, value} = reduce_to_value(v, state)
      {type, line, value}
    end)

    MMap.reduce(key_list, local_state)
  end

  defp reduce_to_value({:eol, _lhs}, _state) do
    nil
  end

  defp reduce_to_value({:parenthesis, expr}, state) do
    reduce_to_value(expr, state)
  end

  defp evaluate_tree([{:assign, {:name, _line, lhs}, rhs} | tail], state) do
    rhs_value = reduce_to_value(rhs, state)
    key = List.to_atom(lhs)

    case rhs_value do
      {:error, line, msg} -> {:error, line, msg}
      value -> evaluate_tree(tail, Map.merge(state, %{key => value}))
    end
  end

  defp evaluate_tree([], state) do
    state
  end

  defp evaluate_tree(_, state) do
    state
  end

  def process_tree(tree) do
    evaluate_tree(tree, %{})
  end

  def parse_and_eval(string) do
    {:ok, tokens, _line} = :cloud_stack_lang_lexer.string(String.to_charlist(string))
    {:ok, tree} = :cloud_stack_lang_parser.parse(tokens)
    process_tree(tree)
  end
end
