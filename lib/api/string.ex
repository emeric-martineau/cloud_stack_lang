defmodule CloudStackLang.String do
  @moduledoc """
  This module contains all routine to help manage strings.
  """

  @doc ~S"""
  Returns the list cleared to simple.

  ## Examples
      iex> CloudStackLang.String.clear_only_escape_quote("'hello world'")
      "hello world"

      iex> CloudStackLang.String.clear_only_escape_quote("'hello \\' world'")
      "hello ' world"

      iex> CloudStackLang.String.clear_only_escape_quote("'hello \\n world'")
      "hello \\n world"

      iex> CloudStackLang.String.clear_only_escape_quote("'hello \\\\ world'")
      "hello \\ world"
  """
  def clear_only_escape_quote({:error, msg}), do: {:error, msg}

  def clear_only_escape_quote(value) do
    quote_char = String.at(value, 0)

    value
    |> String.slice(1..(String.length(value) - 2))
    |> String.replace("\\#{quote_char}", "#{quote_char}")
    |> String.replace("\\\\", "\\")
  end

  @doc ~S"""
  Returns the list cleared to simple or double quote and '\\', '\n', '\r', '\t', '\"', "\'".

  ## Examples
      iex> CloudStackLang.String.clear("'hello world'")
      "hello world"

      iex> CloudStackLang.String.clear("'hello\\nworld'")
      "hello\nworld"

      iex> CloudStackLang.String.clear("'hello\\rworld'")
      "hello\rworld"

      iex> CloudStackLang.String.clear("'hello\\tworld'")
      "hello\tworld"

      iex> CloudStackLang.String.clear("'hello\\\'world'")
      "hello\'world"

      iex> CloudStackLang.String.clear("'hello\\\"world'")
      "hello\"world"

      iex> CloudStackLang.String.clear("'hello\\\\ slashes'")
      "hello\\ slashes"
  """
  def clear({:error, msg}), do: {:error, msg}

  def clear(value) do
    new_value =
      value
      |> String.slice(1..(String.length(value) - 2))
      |> String.replace("\\n", "\n")
      |> String.replace("\\r", "\r")
      |> String.replace("\\t", "\t")
      |> String.replace("\\s", "\s")

    Regex.replace(~r/\\([^$])/, new_value, "\\1")
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
      {:error, "Variable name 'var1' is not declared"}

      iex> CloudStackLang.String.interpolate("'${var1[1][0]}'", %{:vars => %{:var1 => {:array, [{:int, 1}, {:array, [ {:int, 3}]}]}}})
      "'3'"

      iex> CloudStackLang.String.interpolate("'\\${var1}${var1}\\${var1}'", %{:vars => %{:var1 => {:string, "2"}}})
      "'${var1}2${var1}'"
  """
  def interpolate(value, state) do
    replace_var([{0, 0}], value, state)
  end

  defp replace_var([{0, 0}], string, state) do
    new_pos = Regex.run(~R/(\$\{([^}]*)?\})/, string, return: :index, capture: :first)

    replace_var(new_pos, string, state)
  end

  defp replace_var([{start, len}], string, state) do
    check_if_has_previous_backslash([{start, len}], string)
    |> substitute([{start, len}], string, state)
  end

  defp replace_var(nil, string, _state) do
    string
  end

  defp substitute(false, [{start, len}], string, state) do
    start_string = String.slice(string, 0, start)
    # Skip ${ }
    key = String.slice(string, start + 2, len - 3)

    case get(state, key) do
      {:error, msg} ->
        {:error, msg}

      v ->
        create_string_and_continue_parse(start_string, v, [{start, len}], string, state)
    end
  end

  defp substitute(true, [{start, len}], string, state) do
    start_string = String.slice(string, 0, start - 1)
    middle_string  = String.slice(string, start, len)

    create_string_and_continue_parse(start_string, middle_string, [{start, len}], string, state)
  end

  defp create_string_and_continue_parse(start_string, middle_string, [{start, len}], string, state) do
    end_string = String.slice(string, start + len, String.length(string))

    new_pos = Regex.run(~R/(\$\{([^}]*)?\})/, end_string, return: :index, capture: :first)

    start_string <> middle_string <> replace_var(new_pos, end_string, state)
  end

  defp check_if_has_previous_backslash([{0, _len}], _string), do: false

  defp check_if_has_previous_backslash([{start, _len}], string),
       do: String.at(string, start - 1) == "\\"

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
      {:error, _line, msg} -> {:error, msg}
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
