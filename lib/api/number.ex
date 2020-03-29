defmodule CloudStackLang.Number do
  @moduledoc """
  This module contains all routine to perform number operation.
  """

  @doc ~S"""
  Returns integer form string. Must be valid string.

  ## Examples

      iex> CloudStackLang.Number.from_hexa('0xfA')
      {:int, 250}
  """
  def from_hexa(value) do
    {number, _} =
      value
      |> List.to_string()
      |> String.slice(2..-1)
      |> String.downcase()
      |> Integer.parse(16)

    {:int, number}
  end

  @doc ~S"""
  Returns integer form string. Must be valid string.

  ## Examples

      iex> CloudStackLang.Number.from_octal('0o437')
      {:int, 287}
  """
  def from_octal(value) do
    {number, _} =
      value
      |> List.to_string()
      |> String.slice(2..-1)
      |> Integer.parse(8)

    {:int, number}
  end
end
