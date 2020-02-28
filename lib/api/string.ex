defmodule CloudStackLang.String do
  @moduledoc """
  This module contains all routine to help manage strings.
  """

  @doc ~S"""
  Returns the list cleared to simple or double quote and '\\', '\n', '\r', '\t', '\"', "\'".

  ## Examples
      iex> CloudStackLang.String.clear("\'hello world\'")
      "hello world"

      iex> CloudStackLang.String.clear("\"hello\\nworld\"")
      "hello\nworld"

      iex> CloudStackLang.String.clear("\"hello\\rworld\"")
      "hello\rworld"

      iex> CloudStackLang.String.clear("\'hello\\tworld\'")
      "hello\tworld"

      iex> CloudStackLang.String.clear("\"hello\\\'world\"")
      "hello\'world"

      iex> CloudStackLang.String.clear("'hello\\\"world'")
      "hello\"world"
  """
  def clear(value) do
    value
    |> String.slice(1..String.length(value) - 2)
    |> String.replace("\\n", "\n")
    |> String.replace("\\r", "\r")
    |> String.replace("\\t", "\t")
    |> String.replace("\\", "")
  end

  @doc ~S"""
  Replace all ${xxxx} by value.

  ## Examples

      iex> CloudStackLang.String.interpolate("'${var1}'", %{"var1" => 1})
      "'1'"

      iex> CloudStackLang.String.interpolate("'${var1}'", %{"var1" => 1.13})
      "'1.13'"

      iex> CloudStackLang.String.interpolate("'${var1}'", %{"var1" => "2"})
      "'2'"

      iex> CloudStackLang.String.interpolate("'${var1}'", %{"var1" => [1, 2]})
      "'<list>'"

      iex> CloudStackLang.String.interpolate("'${var1}'", %{"var1" => %{ "a" => 2 }})
      "'<map>'"
  """
  def interpolate(value, state) do
    s1 = Regex.replace(~R/^\$\{([^}]*)?\}/, value, fn _, _, key -> unwrap(state[key]) end)
    Regex.replace(~R/(\$\{([^}]*)?\})/, s1, fn _, _, key -> unwrap(state[key]) end)
  end

  # TODO support ${xxx[1]} for array and ${xxx["key"]} for map

  defp unwrap(value) when is_map(value) do
    "<map>"
  end

  defp unwrap(value) when is_list(value) do
    "<list>"
  end

  defp unwrap(value) when is_integer(value) do
    Integer.to_string(value)
  end

  defp unwrap(value) when is_float(value) do
    Float.to_string(value)
  end

  defp unwrap(nil) do
    "null"
  end

  defp unwrap(value) do
    value
  end
end
