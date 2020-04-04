defmodule CloudStackLang.Core.Util do
  @moduledoc ~S"""
    This module contain some functions for core process.

    iex> CloudStackLang.Core.Util.call_if_no_error([1, 2, 3], fn x -> x end, fn x -> x end, ["MyArgs"])
    "MyArgs"

    iex> CloudStackLang.Core.Util.call_if_no_error([1, 2, {:error, 0, "MyError"}], fn x -> x end, fn x -> x end, ["MyArgs"])
    {:error, 0, "MyError"}

    iex> CloudStackLang.Core.Util.merge_list_of_map([%{"a" => 1}, %{"b" => 1}, %{"c" => 1}])
    %{"a" => 1, "b" => 1, "c" => 1}
  """
  alias CloudStackLang.Functions.Executor

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

  # {:error, {3, :cloud_stack_lang_lexer, {:illegal, '"my_value\n}\n'}}, 5}
  # -> {:erro, line, msg}
  def debug_parse({:error, lexer_msg, _line}, false, _state) do
    {line, _, error} = lexer_msg

    msg =
      case error do
        {:illegal, m} -> "Illegal instruction: '#{m}'"
        e -> e
      end

    {:error, line, msg}
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

  def merge_list_of_map([]) do
    %{}
  end

  def merge_list_of_map([last_item]) do
    last_item
  end

  def merge_list_of_map([item | tail]) do
    item
    |> Map.merge(merge_list_of_map(tail))
  end
end
