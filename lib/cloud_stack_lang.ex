defmodule CloudStackLang.Parser do
  alias CloudStackLang.Operator.Add
  alias CloudStackLang.Operator.Div
  alias CloudStackLang.Operator.Mul
  alias CloudStackLang.Operator.Sub
  alias CloudStackLang.Operator.Exp
  alias CloudStackLang.Number

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
    m = Enum.map(value, fn {:map_arg, {:name, _, key}, expr} -> {key, reduce_to_value(expr, state)} end)
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
    m = reduce_to_value({:map, line, assignments}, state)
    {:map, m}
  end

  defp reduce_to_value({:build_empty_array, _open_map}, _state) do
    {:array, []}
  end

  defp reduce_to_value({:build_array, open_map, assignments}, state) do
    {:open_array, line} = open_map
    a = reduce_to_value({:array, line, assignments}, state)
    {:array, a}
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
