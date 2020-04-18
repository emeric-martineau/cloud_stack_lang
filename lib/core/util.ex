#
# Copyright 2020 Cloud Stack Lang Contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
defmodule CloudStackLang.Core.Util do
  @moduledoc ~S"""
  This module contain some functions for core process.
  """
  alias CloudStackLang.Functions.Executor

  @doc ~S"""
  Call gived function if no error detected

  ## Examples

    iex> CloudStackLang.Core.Util.call_if_no_error([1, 2, 3], fn x -> x end, fn x -> x end, ["MyArgs"])
    "MyArgs"

    iex> CloudStackLang.Core.Util.call_if_no_error([1, 2, {:error, 0, "MyError"}], fn x -> x end, fn x -> x end, ["MyArgs"])
    {:error, 0, "MyError"}
  """
  def call_if_no_error(items, fct_reduce, fct_to_call, args) do
    Enum.map(items, fct_reduce)
    |> Enum.filter(fn
      {:error, _line, _msg} -> true
      _ -> false
    end)
    |> case do
      [] -> apply(fct_to_call, args)
      [error | _tail] -> error
    end
  end

  @doc ~S"""
  Display token if debug on.
  """
  def debug_parse({:ok, tokens, line}, true, _state) do
    IO.puts("Stopped at line #{line}\n")
    IO.puts("Tokens:")
    IO.inspect(tokens, pretty: true)
    {:ok, tokens, line}
  end

  def debug_parse({:ok, tokens, line}, false, _state), do: {:ok, tokens, line}

  @doc ~S"""
  Display error if debug mod is disable.

  ## Examples

    iex> CloudStackLang.Core.Util.debug_parse({:error, {3, :cloud_stack_lang_lexer, {:illegal, '"my_value\n}\n'}}, 5}, false, %{})
    {:error, 3, "Illegal instruction: '\"my_value\n}\n'"}
  """
  def debug_parse({:error, lexer_msg, _line}, false, _state) do
    {line, _, error} = lexer_msg

    msg =
      case error do
        {:illegal, m} -> "Illegal instruction: '#{m}'"
        e -> e
      end

    {:error, line, msg}
  end

  @doc ~S"""
  Extract value.
  """
  def extract_value({_type, value}), do: value
  def extract_value({_type, _line, value}), do: value

  @doc ~S"""
  Invoke the function given to parser and manage error.
  """
  def call_function(namespace_call, news_args, line, state) do
    Executor.run(namespace_call, news_args, state)
    |> case do
      {:error, msg} -> {:error, line, msg}
      v -> v
    end
  end

  @doc ~S"""
  Give a list of map and merge all in one map.

  ## Examples

    iex> CloudStackLang.Core.Util.merge_list_of_map([%{"a" => 1}, %{"b" => 1}, %{"c" => 1}])
    %{"a" => 1, "b" => 1, "c" => 1}
  """
  def merge_list_of_map([]), do: %{}

  def merge_list_of_map([last_item]), do: last_item

  def merge_list_of_map([item | tail]),
    do:
      item
      |> Map.merge(merge_list_of_map(tail))

  @doc ~S"""
  Return module in state or empty map if not found.
  """
  def get_module_fct(module_state, namespace) do
    prefix =
      namespace
      |> Enum.at(0)
      |> extract_value()
      |> List.to_string()

    case module_state[:modules_fct][prefix] do
      nil -> %{}
      v -> v
    end
  end
end
