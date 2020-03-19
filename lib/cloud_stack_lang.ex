defmodule CloudStackLang.Parser do
  @moduledoc ~S"""
  This module parse and run code.

  ## Examples

    iex> CloudStackLang.Parser.parse_and_eval("a = 1", false, %{})
    %{a: {:int, 1}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1_000_000", false, %{})
    %{a: {:int, 1000000}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1 + 1", false, %{})
    %{a: {:int, 2}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1 - 1", false, %{})
    %{a: {:int, 0}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 4 / 2", false, %{})
    %{a: {:int, 2}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 7\nb = 4\nresult = a + b * 10 / 2", false, %{})
    %{a: {:int, 7}, b: {:int, 4}, result: {:int, 27}}

    iex> CloudStackLang.Parser.parse_and_eval("a = :toto", false, %{})
    %{a: {:atom, :toto}}

    iex> CloudStackLang.Parser.parse_and_eval("/*\nThis is multi line comment\n*/\na = :toto", false, %{})
    %{a: {:atom, :toto}}

    iex> CloudStackLang.Parser.parse_and_eval("// This is single line comment\na = :toto", false, %{})
    %{a: {:atom, :toto}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1\nb='no interpolate ${a} \\' with single quote'", false, %{})
    %{a: {:int, 1}, b: {:string, "no interpolate ${a} ' with single quote"}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1\nb=\"interpolate ${a} \\\" with double quote\"", false, %{})
    %{a: {:int, 1}, b: {:string, "interpolate 1 \" with double quote"}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1.3", false, %{})
    %{a: {:float, 1.3}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1.2_3_4", false, %{})
    %{a: {:float, 1.234}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1.2_3_4e2_3", false, %{})
    %{a: {:float, 1.234e23}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1.3e2", false, %{})
    %{a: {:float, 1.3e2}}

    iex> CloudStackLang.Parser.parse_and_eval("a = -1.3e2", false, %{})
    %{a: {:float, -1.3e2}}

    iex> CloudStackLang.Parser.parse_and_eval("a = -1", false, %{})
    %{a: {:int, -1}}

    iex> CloudStackLang.Parser.parse_and_eval("a = {}", false, %{})
    %{a: {:map, %{}}}

    iex> CloudStackLang.Parser.parse_and_eval("a = { :a = 2 }", false, %{})
    %{a: {:map, %{:a => {:int, 2}}}}

    iex> CloudStackLang.Parser.parse_and_eval("a = { :a = 2 'b' = 3}", false, %{})
    %{a: {:map, %{:a => {:int, 2}, "b" => {:int, 3}}}}

    iex> CloudStackLang.Parser.parse_and_eval("a = []", false, %{})
    %{a: {:array, []}}

    iex> CloudStackLang.Parser.parse_and_eval("a = [ 2 ]", false, %{})
    %{a: {:array, [ {:int, 2} ]}}

    iex> CloudStackLang.Parser.parse_and_eval("a = [ 2 3 ]", false, %{})
    %{a: {:array, [ {:int, 2}, {:int, 3} ]}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 0xfa", false, %{})
    %{a: {:int, 250}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 0xFA", false, %{})
    %{a: {:int, 250}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 0o531", false, %{})
    %{a: {:int, 345}}

    iex> CloudStackLang.Parser.parse_and_eval("a = (1 * (3 + 5))", false, %{})
    %{a: {:int, 8}}

    iex> CloudStackLang.Parser.parse_and_eval("a = { :a = 1}\nb = a[:a]", false, %{})
    %{a: {:map, %{ :a => {:int, 1}}}, b: {:int, 1}}

    iex> CloudStackLang.Parser.parse_and_eval("a = { :a = { :b = 2 } }\nb = a[:a][:b]", false, %{})
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
  alias CloudStackLang.Functions.Base, as: FctBase

  defp compute_operation(lhs, rhs, state, function) do
    lvalue = reduce_to_value(lhs, state)
    rvalue = reduce_to_value(rhs, state)

    ret = function.(lvalue, rvalue)

    case ret do
      {:error, msg} ->
        {_, line, _} = lhs
        {:error, line, msg}
      r -> r
    end
  end

  defp call_if_no_error(items, fct_reduce, fct_to_call, args) do
    elems = Enum.map(items, fct_reduce)

    errors = Enum.filter(elems, fn
      {:error, _line, _msg} -> true
      _ -> false
    end)

    case errors do
      [] -> apply(fct_to_call, args)
      [ error | _tail ] -> error
    end
  end

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

    case s do
      {:error, line, msg} -> {:error, line, msg}
      v -> {:string, v}
    end
  end

  defp reduce_to_value({:map, _line, value}, state) do
    list_of_key_value_compute = Enum.map(value,
      fn {:map_arg, key, expr} ->
        {_, k} = reduce_to_value(key, state)
        {k, reduce_to_value(expr, state)}
      end)

    fct = fn data -> {:map, Map.new(data)} end
    fct_reduce = fn {_, msg} -> msg end

    call_if_no_error(list_of_key_value_compute, fct_reduce, fct, [list_of_key_value_compute])
  end

  defp reduce_to_value({:array, _line, value}, state) do
    list_of_value = Enum.map(value, fn v -> reduce_to_value(v, state) end)

    fct = fn data -> {:array, data} end
    fct_reduce = fn msg -> msg end

    call_if_no_error(list_of_value, fct_reduce, fct, [list_of_value])
  end

  defp reduce_to_value({:int, _line, value}, _state) do
    v = value
    |> List.to_string
    |> String.replace("_", "")

    {:int, String.to_integer(v)}
  end

  defp reduce_to_value({:float, _line, value}, _state) do
    v = value
    |> List.to_string
    |> String.replace("_", "")

    {:float, String.to_float(v)}
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
    compute_operation(lhs, rhs, state, &Add.reduce/2)
  end

  defp reduce_to_value({:sub_op, lhs, rhs}, state) do
    compute_operation(lhs, rhs, state, &Sub.reduce/2)
  end

  defp reduce_to_value({:mul_op, lhs, rhs}, state) do
    compute_operation(lhs, rhs, state, &Mul.reduce/2)
  end

  defp reduce_to_value({:div_op, lhs, rhs}, state) do
    compute_operation(lhs, rhs, state, &Div.reduce/2)
  end

  defp reduce_to_value({:exp_op, lhs, rhs}, state) do
    compute_operation(lhs, rhs, state, &Exp.reduce/2)
  end

  defp reduce_to_value({:map_get, var_name, access_key_list}, state) do
    # Get variable value
    local_state = reduce_to_value(var_name, state)

    check_map_variable(local_state, access_key_list, state)
  end

  defp reduce_to_value({:parenthesis, expr}, state) do
    reduce_to_value(expr, state)
  end

  defp reduce_to_value({:fct_call, {:name, line, fct_name}, args}, state) do
    news_args = Enum.map(args, fn a -> reduce_to_value(a, state) end)

    fct_reduce = fn data -> data end

    call_if_no_error(news_args, fct_reduce, &call_function/3, [List.to_string(fct_name), news_args, line])
  end

  defp call_function(fct_name, news_args, line) do
    return_value = FctBase.run(fct_name, news_args)

    case return_value do
      {:error, msg} -> {:error, line, msg}
      _ -> return_value
    end
  end

  defp check_map_variable({:error, line, msg}, _access_key_list, _state) do
    {:error, line, msg}
  end

  defp check_map_variable(local_state, access_key_list, state) do
    # Parse all arguments
    key_list = Enum.map(access_key_list, fn v ->
      {_, line, _} = v
      case reduce_to_value(v, state) do
        {:error, line, msg} -> {:error, line, msg}
        {type, value} -> {type, line, value}
      end
    end)

    fct_reduce = fn data -> data end

    call_if_no_error(key_list, fct_reduce, &MMap.reduce/2, [key_list, local_state])
  end

  defp evaluate_tree([{:assign, {:name, _line, variable_name}, variable_expr_value} | tail], state) do
    value = reduce_to_value(variable_expr_value, state)
    key = List.to_atom(variable_name)

    case value do
      {:error, line, msg} -> {:error, line, msg}
      value -> evaluate_tree(tail, Map.merge(state, %{key => value}))
    end
  end

  defp evaluate_tree([{:fct_call, {:name, line, fct_name}, args} | tail], state) do
    return_value = reduce_to_value({:fct_call, {:name, line, fct_name}, args}, state)

    case return_value do
      {:error, line, msg} -> {:error, line, msg}
      _ -> evaluate_tree(tail, state)
    end
  end

  defp evaluate_tree([], state) do
    state
  end

  defp evaluate_tree(_, state) do
    state
  end

  defp process_tree({:error, err}, true, _state) do
    IO.puts "\nParse error"
    IO.inspect err

    err
  end

  defp process_tree({:error, err}, false, _state) do
    err
  end

  defp process_tree({:ok, tree}, true, state) do
    IO.puts "\nParse tree"
    IO.inspect tree, pretty: true

    result = evaluate_tree(tree, state)

    IO.puts "\nFinal state"
    IO.inspect result, pretty: true

    result
  end

  defp process_tree({:ok, tree}, false, state) do
    evaluate_tree(tree, state)
  end

  defp process_parse({:error, result}, _debug, _state) do
    {:error, result}
  end

  defp process_parse({:ok, tokens, _line}, debug, state) do
    :cloud_stack_lang_parser.parse(tokens)
    |> process_tree(debug, state)
  end

  defp debug_parse({:ok, tokens, line}, true, _state) do
    IO.puts "Stopped at line #{line}\n"
    IO.puts "Tokens:"
    IO.inspect tokens, pretty: true
    {:ok, tokens, line}
  end

  defp debug_parse({:ok, tokens, line}, false, _state) do
    {:ok, tokens, line}
  end

  def parse_and_eval(string, debug, state) do
    :cloud_stack_lang_lexer.string(String.to_charlist(string))
    |> debug_parse(debug, state)
    |> process_parse(debug, state)
  end
end
