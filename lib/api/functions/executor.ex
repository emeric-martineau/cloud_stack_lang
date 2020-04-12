defmodule CloudStackLang.Functions.Executor do
  @moduledoc """
  This module contains all base functions, available in any context.
    <function name as atom> => :fct, [args type], function
    <function name as atom> => :manager, function

    args type  : array with list of arg type of function
    function   : the function must return {type, value} or {:error, msg}

    type list:
      :int
      :float
      :string
      :array
      :map
      :void
    
    ## Examples
      iex> CloudStackLang.Functions.Executor.run([{:name, 1, 'base64'}, {:name, 1, 'encode'}], [{:string, "hello"}], %{:fct => %{:base64 => %{:encode => {:fct, [:string], fn x -> {:string, x} end}}}})
      {:string, "hello"}

      iex> CloudStackLang.Functions.Executor.run([{:name, 1, 'base64'}, {:name, 1, 'encode'}], [{:int, 1}], %{:fct => %{:base64 => %{:encode => {:fct, [:string], fn x -> {:string, x} end}}}})
      {:error, "Bad type argument for 'base64.encode'. The argument n°1 waiting 'string' and given 'int'"}

      iex> CloudStackLang.Functions.Executor.run([{:name, 1, 'base64'}, {:name, 1, 'encode'}], [{:string, "hello"}, {:int, 1}], %{:fct => %{:base64 => %{:encode => {:fct, [:string], fn x -> {:string, x} end}}}})
      {:error, "Wrong arguments for 'base64.encode'. Waiting 1, given 2"}

      iex> CloudStackLang.Functions.Executor.run([{:name, 1, 'manager'}], [{:string, "hello"}], %{:fct => %{:manager => {:manager, fn _namespace, _args -> {:int, 45} end}}})
      {:int, 45}

      iex> CloudStackLang.Functions.Executor.run([{:name, 1, 'ns1'}, {:name, 1, 'ns2'}, {:name, 1, 'ns3'}], [{:string, "hello"}], %{:fct => %{:ns1 => {:manager, fn _namespace, _args -> {:int, 45} end}}})
      {:int, 45}
  """
  def run(namespace_call, args, state) do
    fct_entry = get_function_entry(namespace_call, state[:fct])

    call(namespace_call, args, fct_entry)
  end

  defp call(namespace_call, _args, nil),
    do: {:error, "Function '#{get_function_name(namespace_call)}' not found"}

  defp call(namespace_call, args, {:manager, fct_ptr}), do: apply(fct_ptr, [namespace_call, args])

  defp call(namespace_call, args, {:fct, args_type, fct_ptr})
       when length(args) == length(args_type),
       do: exec(namespace_call, args, {:fct, args_type, fct_ptr})

  defp call(namespace_call, args, {:fct, args_type, _fct_ptr}),
    do:
      {:error,
       "Wrong arguments for '#{get_function_name(namespace_call)}'. Waiting #{length(args_type)}, given #{
         length(args)
       }"}

  defp exec(namespace_call, args, {:fct, args_type, fct_ptr}) do
    given_args_type = Enum.map(args, fn {type, _value} -> type end)
    given_args_value = Enum.map(args, fn {_type, value} -> value end)

    case check_args_type(namespace_call, args_type, given_args_type, 1) do
      {:error, msg} -> {:error, msg}
      _ -> apply(fct_ptr, given_args_value)
    end
  end

  defp check_args_type(
         namespace_call,
         [waiting_type | tail_waiting],
         [given_type | tail_given],
         index
       )
       when waiting_type == given_type,
       do: check_args_type(namespace_call, tail_waiting, tail_given, index + 1)

  defp check_args_type(
         namespace_call,
         [waiting_type | _tail_waiting],
         [given_type | _tail_given],
         index
       ),
       do:
         {:error,
          "Bad type argument for '#{get_function_name(namespace_call)}'. The argument n°#{index} waiting '#{
            waiting_type
          }' and given '#{given_type}'"}

  defp check_args_type(_function_name, [], [], _index), do: true

  defp get_function_entry([namespace | []], functions) do
    {:name, _line, fct_name} = namespace

    functions[List.to_atom(fct_name)]
  end

  defp get_function_entry([_namespace | _tail], nil), do: nil

  defp get_function_entry([_namespace | _tail], {:manager, fct}), do: {:manager, fct}

  defp get_function_entry([namespace | tail], functions) do
    {:name, _line, fct_name} = namespace

    get_function_entry(tail, functions[List.to_atom(fct_name)])
  end

  defp get_function_name(namespace_call),
    do:
      namespace_call
      |> Enum.map(fn {:name, _line, name} -> name end)
      |> Enum.join(".")
end
