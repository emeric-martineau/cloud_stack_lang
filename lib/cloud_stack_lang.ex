defmodule CloudStackLang.Parser do
  alias CloudStackLang.Operator.Add
  alias CloudStackLang.Operator.Div
  alias CloudStackLang.Operator.Mul
  alias CloudStackLang.Operator.Sub

  defp reduce_to_value({:simple_string, _line, value}, _state) do
    CloudStackLang.List.String.clear(value)
  end

  defp reduce_to_value({:interpolate_string, _line, value}, _state) do
    # TODO interpolation
    CloudStackLang.List.String.clear(value)
  end

  defp reduce_to_value({:map, _line, value}, _state) do
    # TODO
    value
  end

  defp reduce_to_value({:array, _line, value}, state) do
    Enum.map(value, fn v -> reduce_to_value(v, state) end)
  end

  defp reduce_to_value({:int, _line, value}, _state) do
    List.to_integer(value)
  end

  defp reduce_to_value({:float, _line, value}, _state) do
    List.to_float(value)
  end

  defp reduce_to_value({:atom, _line, atom_name}, _state) do
    [_ | atom] = atom_name
    List.to_atom(atom)
  end

  defp reduce_to_value({:build_empty_map, _open_map}, _state) do
    %{}
  end

  defp reduce_to_value({:build_map, open_map, assignments}, _state) do
    {:open_map, line} = open_map
    {:map, line, assignments}
  end

  defp reduce_to_value({:build_empty_array, _open_map}, _state) do
    []
  end

  defp reduce_to_value({:build_array, open_map, assignments}, _state) do
    {:open_array, line} = open_map
    {:array, line, assignments}
  end

  defp reduce_to_value({:name, line, var_name}, state) do
    case state[var_name] do
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

  defp evaluate_tree([{:assign, {:name, _line, lhs}, rhs} | tail], state) do
    rhs_value = reduce_to_value(rhs, state)

    case rhs_value do
      {:error, line, msg} -> {:error, line, msg}
      value -> evaluate_tree(tail, Map.merge(state, %{lhs => value}))
    end
  end

  defp evaluate_tree([], state) do
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
