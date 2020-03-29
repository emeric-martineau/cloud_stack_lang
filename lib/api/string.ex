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
  def clear({:error, line, msg}) do
    {:error, line, msg}
  end

  def clear(value) do
    value
    |> String.slice(1..(String.length(value) - 2))
    |> String.replace("\\n", "\n")
    |> String.replace("\\r", "\r")
    |> String.replace("\\t", "\t")
    |> String.replace("\\s", "\s")
    |> String.replace("\\", "")
  end

  @doc ~S"""
  Replace all ${xxxx} by value.

  ## Examples

      iex> CloudStackLang.String.interpolate("'${var1}'", %{:vars => %{:var1 => {:int, 1}}})
      "'1'"

      iex> CloudStackLang.String.interpolate("'${var1}'", %{:vars => %{:var1 => {:float, 1.13}}})
      "'1.13'"

      iex> CloudStackLang.String.interpolate("'${var1}'", %{:vars => %{:var1 => {:string, "2"}}})
      "'2'"

      iex> CloudStackLang.String.interpolate("'${var1}'", %{:vars => %{:var1 => {:array, [1, 2]}}})
      "'<list>'"

      iex> CloudStackLang.String.interpolate("'${var1}'", %{:vars => %{:var1 => {:map, %{ "a" => 2 }}}})
      "'<map>'"

      iex> CloudStackLang.String.interpolate("'${var1}'", %{:vars => %{:e => 3}})
      {:error, 1, "Variable name 'var1' is not declared"}

      iex> CloudStackLang.String.interpolate("'${var1[1][0]}'", %{:vars => %{:var1 => {:array, [{:int, 1}, {:array, [ {:int, 3}]}]}}})
      "'3'"
  """
  def interpolate(value, state) do
    replace_var([{0, 0}], value, state)
  end

  defp replace_var([{0, 0}], string, state) do
    new_pos = Regex.run(~R/(\$\{([^}]*)?\})/, string, return: :index, capture: :first)

    replace_var(new_pos, string, state)
  end

  defp replace_var([{start, len}], string, state) do
    start_string = String.slice(string, 0, start)
    # Skip ${ }
    key = String.slice(string, start + 2, len - 3)

    value_to_replace = get(state, key)

    case value_to_replace do
      {:error, line, msg} ->
        {:error, line, msg}

      v ->
        end_string = String.slice(string, start + len, String.length(string))

        new_pos = Regex.run(~R/(\$\{([^}]*)?\})/, end_string, return: :index, capture: :first)

        start_string <> v <> replace_var(new_pos, end_string, state)
    end
  end

  defp replace_var(nil, string, _state) do
    string
  end

  defp get(state, key) do
    value =
      CloudStackLang.Parser.parse_and_eval(
        "result=" <> key,
        false,
        state[:vars],
        state[:fct],
        state[:modules_fct]
      )

    case value do
      {:error, line, msg} -> {:error, line, msg}
      v -> unwrap(v[:vars][:result])
    end
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

  defp unwrap(value) do
    value
  end
end
