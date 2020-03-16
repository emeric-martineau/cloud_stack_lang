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
    |> String.replace("\\s", "\s")
    |> String.replace("\\", "")
  end

  @doc ~S"""
  Replace all ${xxxx} by value.

  ## Examples

      iex> CloudStackLang.String.interpolate("'${var1}'", %{:var1 => {:int, 1}})
      "'1'"

      iex> CloudStackLang.String.interpolate("'${var1}'", %{:var1 => {:float, 1.13}})
      "'1.13'"

      iex> CloudStackLang.String.interpolate("'${var1}'", %{:var1 => {:string, "2"}})
      "'2'"

      iex> CloudStackLang.String.interpolate("'${var1}'", %{:var1 => {:array, [1, 2]}})
      "'<list>'"

      iex> CloudStackLang.String.interpolate("'${var1}'", %{:var1 => {:map, %{ "a" => 2 }}})
      "'<map>'"

      iex> CloudStackLang.String.interpolate("'${var1}'", %{:e => 3})
      "'null'"
  """
  def interpolate(value, state) do
    # First replace ${xxx} at start of line
    s1 = Regex.replace(~R/^\$\{([^}]*)?\}/, value, fn _, _, key -> get(state, key) end)
    # then replace all ${xxx}
    Regex.replace(~R/(\$\{([^}]*)?\})/, s1, fn _, _, key -> get(state, key) end)
  end

  # TODO support ${xxx[1]} for array and ${xxx["key"]} for map
  # TODO raise error if variable not found

  defp get(state, key) do
    k = String.to_atom(key)
    unwrap(state[k])
  end

  defp unwrap({:string, value}) do
    value
  end

  defp unwrap({:map, _value}) do
    "<map>"
  end

  defp unwrap({:array, _value}) do
    "<list>"
  end

  defp unwrap({:int, value}) do
    Integer.to_string(value)
  end

  defp unwrap({:float, value}) do
    Float.to_string(value)
  end

  defp unwrap(nil) do
    "null"
  end

  defp unwrap(value) do
    value
  end
end
