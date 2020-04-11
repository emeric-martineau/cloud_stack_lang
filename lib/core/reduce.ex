defmodule CloudStackLang.Core.Reduce do
  @moduledoc ~S"""
    This module contain some functions for core process.
  """
  alias CloudStackLang.Operator.Add
  alias CloudStackLang.Operator.Div
  alias CloudStackLang.Operator.Mul
  alias CloudStackLang.Operator.Sub
  alias CloudStackLang.Operator.Exp
  alias CloudStackLang.Number
  alias CloudStackLang.Map, as: MMap
  alias CloudStackLang.Core.Util

  def check_map_variable({:error, line, msg}, _access_key_list, _state), do: {:error, line, msg}

  def check_map_variable(local_state, access_key_list, state) do
    # Parse all arguments
    key_list =
      Enum.map(access_key_list, fn v ->
        {_, line, _} = v

        case to_value(v, state) do
          {:error, line, msg} -> {:error, line, msg}
          {type, value} -> {type, line, value}
        end
      end)

    fct_reduce = fn data -> data end

    Util.call_if_no_error(key_list, fct_reduce, &MMap.reduce/2, [key_list, local_state])
  end

  def reduce_map_key_name({:map_arg, key, expr}, state) do
    # In case of module, we wan can use name to key for more readable
    {_, k} =
      case key do
        {:name, _line, value} ->
          case state[:in_module] do
            # we are in module, we don't resole variable name
            true -> {:name, List.to_string(value)}
            _ -> to_value(key, state)
          end

        k ->
          to_value(k, state)
      end

    {k, to_value(expr, state)}
  end

  def compute_operation(lhs, rhs, state, function) do
    lvalue = to_value(lhs, state)
    rvalue = to_value(rhs, state)

    function.(lvalue, rvalue)
    |> case do
      {:error, msg} ->
        {_, line, _} = lhs

        # Sorry, it's ugly code. But in case of error lhs can be {:add_op, {:interpolate_string, 2, '"trtrt"'}, {:int, 2, '3'}}
        # or can be {:interpolate_string, 2, '"trtrt"'}
        case line do
          {_, l, _} ->
            {:error, l, msg}

          l ->
            {:error, l, msg}
        end

      r ->
        r
    end
  end

  def to_value({:simple_string, _line, value}, _state) do
    s =
      value
      |> List.to_string()
      |> CloudStackLang.String.clear_only_escape_quote()

    {:string, s}
  end

  def to_value({:interpolate_string, line, value}, state) do
    value
    |> List.to_string()
    |> CloudStackLang.String.clear()
    |> CloudStackLang.String.interpolate(state)
    |> case do
      {:error, msg} -> {:error, line, msg}
      v -> {:string, v}
    end
  end

  def to_value({:map, _line, value}, state) do
    list_of_key_value_compute = Enum.map(value, fn v -> reduce_map_key_name(v, state) end)

    fct = fn data -> {:map, Map.new(data)} end
    fct_reduce = fn {_, msg} -> msg end

    Util.call_if_no_error(list_of_key_value_compute, fct_reduce, fct, [list_of_key_value_compute])
  end

  def to_value({:array, _line, value}, state) do
    list_of_value = Enum.map(value, fn v -> to_value(v, state) end)

    fct = fn data -> {:array, data} end
    fct_reduce = fn msg -> msg end

    Util.call_if_no_error(list_of_value, fct_reduce, fct, [list_of_value])
  end

  def to_value({:int, _line, value}, _state) do
    v =
      value
      |> List.to_string()
      |> String.replace("_", "")

    {:int, String.to_integer(v)}
  end

  def to_value({:float, _line, value}, _state) do
    v =
      value
      |> List.to_string()
      |> String.replace("_", "")

    {:float, String.to_float(v)}
  end

  def to_value({:hexa, _line, value}, _state), do: Number.from_hexa(value)

  def to_value({:octal, _line, value}, _state), do: Number.from_octal(value)

  def to_value({:atom, _line, atom_name}, _state) do
    [_ | atom] = atom_name
    {:atom, List.to_atom(atom)}
  end

  def to_value({:build_empty_map, _open_map}, _state), do: {:map, %{}}

  def to_value({:build_map, open_map, assignments}, state) do
    {:open_map, line} = open_map
    to_value({:map, line, assignments}, state)
  end

  def to_value({:build_empty_array, _open_map}, _state), do: {:array, []}

  def to_value({:build_array, open_map, assignments}, state) do
    {:open_array, line} = open_map
    to_value({:array, line, assignments}, state)
  end

  def to_value({:name, line, var_name}, state) do
    v_name = List.to_atom(var_name)

    case v_name do
      :true ->
        {:bool, true}

      :false ->
        {:bool, false}

      _ ->
        case state[:vars][v_name] do
          nil ->
            {:error, line, "Variable name '#{var_name}' is not declared"}

          value ->
            value
        end
    end
  end

  def to_value({:add_op, lhs, rhs}, state), do: compute_operation(lhs, rhs, state, &Add.reduce/2)

  def to_value({:sub_op, lhs, rhs}, state), do: compute_operation(lhs, rhs, state, &Sub.reduce/2)

  def to_value({:mul_op, lhs, rhs}, state), do: compute_operation(lhs, rhs, state, &Mul.reduce/2)

  def to_value({:div_op, lhs, rhs}, state), do: compute_operation(lhs, rhs, state, &Div.reduce/2)

  def to_value({:exp_op, lhs, rhs}, state), do: compute_operation(lhs, rhs, state, &Exp.reduce/2)

  def to_value({:map_get, var_name, access_key_list}, state),
    # Get variable value
    do:
      to_value(var_name, state)
      |> check_map_variable(access_key_list, state)

  def to_value({:parenthesis, expr}, state), do: to_value(expr, state)

  def to_value({:fct_call, namespace, args}, state) do
    news_args = Enum.map(args, fn a -> to_value(a, state) end)

    fct_reduce = fn data -> data end

    {:name, line, _name} = List.last(namespace)

    Util.call_if_no_error(news_args, fct_reduce, &Util.call_function/4, [
      namespace,
      news_args,
      line,
      state
    ])
  end
end
