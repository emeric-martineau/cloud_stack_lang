defmodule CloudStackLang.Functions.Executor do
  @moduledoc """
  This module contains all base functions, available in any context.

    ## Examples
      iex> CloudStackLang.Functions.Executor.run(
        [{:name, 1, 'base64'}, {:name, 1, 'encode'}],
        [{:string, "hello"}],
        %{
          :base64 => %{
            :encode => {[:string], :string, fn x -> {:ok, x} end},
          }
        })
      {:string, "hello"}

      iex> CloudStackLang.Functions.Executor.run(
        [{:name, 1, 'base64'}, {:name, 1, 'encode'}],
        [{:int, 1}],
        %{
          :base64 => %{
            :encode => {[:string], :string, fn x -> {:ok, x} end},
          }
        })
      {:error, "Bad type argument for 'base64.decode'. The argument n°1 waiting 'string' and given 'int'"}

      iex> CloudStackLang.Functions.Executor.run(
        [{:name, 1, 'base64'}, {:name, 1, 'encode'}],
        [{:string, "hello"}, {:int, 1}],
        %{
          :base64 => %{
            :encode => {[:string], :string, fn x -> {:ok, x} end},
          }
        })
      {:error, "Bad arguments for 'base64.decode'. Waiting 1, given 2"}
  """
  def run(namespace_call, args, state) do
    fct_entry = get_function_entry(namespace_call, state[:fct])

    function_name = namespace_call
      |> Enum.map(fn {:name, _line, name} -> name end)
      |> Enum.join(".")

    case call(function_name, args, fct_entry) do
      {:ok, value} ->
        {_args_type, return_type, _fct_ptr} = fct_entry
        {return_type, value}
      v -> v
    end
  end

  defp call(function_name, _args, nil), do: {:error, "Function '#{function_name}' not found"}

  defp call(function_name, args, fct_entry) do
    {args_type, _return_type, _fct_ptr} = fct_entry

    cond do
      length(args) == length(args_type) -> exec(function_name, args, fct_entry)
      true -> {:error, "Bad arguments for '#{function_name}'. Waiting #{length(args_type)}, given #{length(args)}"}
    end
  end

  defp exec(function_name, args, fct_entry) do
    given_args_type = Enum.map(args, fn {type, _value} -> type end)
    given_args_value = Enum.map(args, fn {_type, value} -> value end)

    {args_type, _return_type, fct_ptr} = fct_entry

    case check_args_type(function_name, args_type, given_args_type, 1) do
      {:error, msg} -> {:error, msg}
      _ -> apply(fct_ptr, given_args_value)
    end
  end

  defp check_args_type(function_name, [waiting_type | tail_waiting], [given_type | tail_given], index) do
    case waiting_type == given_type do
      true -> check_args_type(function_name, tail_waiting, tail_given, index + 1)
      _ -> {:error, "Bad type argument for '#{function_name}'. The argument n°#{index} waiting '#{waiting_type}' and given '#{given_type}'"}
    end
  end

  defp check_args_type(_function_name, [], [], _index), do: true

  defp get_function_entry([namespace | []], functions) do
    {:name, _line, fct_name} = namespace

    functions[List.to_atom(fct_name)]
  end

  defp get_function_entry([_namespace | _tail], nil), do: nil

  defp get_function_entry([namespace | tail], functions) do
    {:name, _line, fct_name} = namespace

    get_function_entry(tail, functions[List.to_atom(fct_name)])
  end
end