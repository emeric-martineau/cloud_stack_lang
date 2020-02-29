defmodule CloudStackLang.Operator.Add do
  @moduledoc """
  This module contains all routine to perform add operation.

  ## Examples

    iex> CloudStackLang.Operator.Add.reduce(1, 1)
    2

    iex> CloudStackLang.Operator.Add.reduce({:error, 1, "hello"}, 1)
    {:error, 1, "hello"}

    iex> CloudStackLang.Operator.Add.reduce(1, {:error, 1, "hello"})
    {:error, 1, "hello"}
  """
  def reduce({:error, line, msg}, _rvalue) do
    {:error, line, msg}
  end

  def reduce(_lvalue, {:error, line, msg}) do
    {:error, line, msg}
  end

  def reduce(lvalue, rvalue) do
    lvalue + rvalue
  end

  # TODO support for string, array and map
end
