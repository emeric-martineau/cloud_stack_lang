defmodule CloudStackLang.Core.Util do
  @moduledoc ~S"""
    This module contain some functions for core process.
  """
  alias CloudStackLang.Functions.Executor

  def get_module_type(namespace_call),
    do:
      namespace_call
      |> Enum.map(fn {:name, _line, name} -> name end)
      |> Enum.map(&List.to_string/1)
      |> Enum.join("::")

  def call_if_no_error(items, fct_reduce, fct_to_call, args) do
    elems = Enum.map(items, fct_reduce)

    errors =
      Enum.filter(elems, fn
        {:error, _line, _msg} -> true
        _ -> false
      end)

    case errors do
      [] -> apply(fct_to_call, args)
      [error | _tail] -> error
    end
  end

  def debug_parse({:ok, tokens, line}, true, _state) do
    IO.puts("Stopped at line #{line}\n")
    IO.puts("Tokens:")
    IO.inspect(tokens, pretty: true)
    {:ok, tokens, line}
  end

  def debug_parse({:ok, tokens, line}, false, _state) do
    {:ok, tokens, line}
  end

  def extract_value({_type, value}) do
    value
  end

  def call_function(namespace_call, news_args, line, state) do
    return_value = Executor.run(namespace_call, news_args, state)

    case return_value do
      {:error, msg} -> {:error, line, msg}
      _ -> return_value
    end
  end
end
