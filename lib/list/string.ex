defmodule CloudStackLang.List.String do
  @moduledoc """
  This module contains all routine to help manage strings.
  """

  @doc ~S"""
  Returns the list cleared to simple or double quote and '\\', '\n', '\r', '\t', '\"', "\'".

  ## Examples

      iex> CloudStackLang.List.String.clear('\'hello world\'')
      "hello world"

      iex> CloudStackLang.List.String.clear('\'hello\\nworld\'')
      "hello\nworld"

      iex> CloudStackLang.List.String.clear('\'hello\\rworld\'')
      "hello\rworld"

      iex> CloudStackLang.List.String.clear('\'hello\\tworld\'')
      "hello\tworld"

      iex> CloudStackLang.List.String.clear('\'hello\\\'world\'')
      "hello\'world"
  """
  def clear(value) do
    [_ | end_string] = value

    end_string
    |> List.delete_at(Kernel.length(end_string) - 1)
    |> List.to_string
    |> String.replace("\\n", "\n")
    |> String.replace("\\r", "\r")
    |> String.replace("\\t", "\t")
    |> String.replace("\\", "")
  end

end
