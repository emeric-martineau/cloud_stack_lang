defmodule CloudStackLang.Operator.Exp do
  @moduledoc """
  This module contains all routine to perform add operation.

  ## Examples

    iex> CloudStackLang.Operator.Exp.reduce(2, 0)
    1

    iex> CloudStackLang.Operator.Exp.reduce(2, 2)
    4

    iex> CloudStackLang.Operator.Exp.reduce(2, 3)
    8

    iex> CloudStackLang.Operator.Exp.reduce(2.8, 2.9)
    19.80424502306346

    iex> CloudStackLang.Operator.Exp.reduce({:error, 1, "hello"}, 1)
    {:error, 1, "hello"}

    iex> CloudStackLang.Operator.Exp.reduce(1, {:error, 1, "hello"})
    {:error, 1, "hello"}
  """
  def reduce({:error, line, msg}, _rvalue) do
    {:error, line, msg}
  end

  def reduce(_lvalue, {:error, line, msg}) do
    {:error, line, msg}
  end

  def reduce(lvalue, rvalue) do
    Math.pow(lvalue, rvalue)
  end

end
