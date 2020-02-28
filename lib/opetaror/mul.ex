defmodule CloudStackLang.Operator.Mul do
  @moduledoc """
  This module contains all routine to perform mul operation.

  ## Examples

    iex> CloudStackLang.Operator.Mul.reduce(2, 2)
    4

    iex> CloudStackLang.Operator.Mul.reduce({:error, 1, "hello"}, 1)
    {:error, 1, "hello"}

    iex> CloudStackLang.Operator.Mul.reduce(1, {:error, 1, "hello"})
    {:error, 1, "hello"}
  """
  def reduce({:error, line, msg}, _rvalue) do
    {:error, line, msg}
  end

  def reduce(_lvalue, {:error, line, msg}) do
    {:error, line, msg}
  end

  def reduce(lvalue, rvalue) do
    lvalue * rvalue
  end
end
