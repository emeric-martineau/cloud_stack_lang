defmodule CloudStackLang.Functions.Base do
  @moduledoc """
  This module contains all base functions, available in any context.

    ## Examples
      iex> CloudStackLang.Functions.Base.run("base64_encode", [{:string, "hello"}])
      {:string, "aGVsbG8="}

      iex> CloudStackLang.Functions.Base.run("base64_decode", [{:string, "aGVsbG8="}])
      {:string, "hello"}

      iex> CloudStackLang.Functions.Base.run("base64_decode", [{:int, 1}])
      {:error, "Bad type argument for 'base64_decode'. The argument n°1 waiting 'string' and given 'int'"}

      iex> CloudStackLang.Functions.Base.run("base64_decode", [{:string, "aGVsbG8="}, {:int, 1}])
      {:error, "Bad arguments for 'base64_decode'. Waiting 1, given 2"}
  """
  alias CloudStackLang.Functions.BaseWrapper

  # TODO add support base62.encode() base64.decode() notation

  # <function name as atom> => [args type], return type, function, return fct transformer
  @functions %{
    :base64_decode => {[:string], :string, &Base.decode64/1},
    :base64_encode => {[:string], :string, &BaseWrapper.encode64/1},
  }

  def run(function_name, args) do
    fct_entry = @functions[String.to_atom(function_name)]

    call(function_name, args, fct_entry)

    case call(function_name, args, fct_entry) do
      {:ok, value} ->
        {_args_type, return_type, _fct_ptr} = fct_entry
        {return_type, value}
      v -> v
    end
  end

  defp call(function_name, _args, nil) do
    {:error, "Function '#{function_name}' not found"}
  end

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
end