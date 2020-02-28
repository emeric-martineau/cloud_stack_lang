defmodule CloudStackLang.Operator.Div do
  @moduledoc """
  This module contains all routine to perform sub operation.

  ## Examples

    iex> CloudStackLang.Operator.Div.reduce(6, 2)
    3

    iex> CloudStackLang.Operator.Div.reduce(8.0, 2)
    4.0

    iex> CloudStackLang.Operator.Div.reduce(8, 2.0)
    4.0

    iex> CloudStackLang.Operator.Div.reduce({:error, 1, "hello"}, 1)
    {:error, 1, "hello"}

    iex> CloudStackLang.Operator.Div.reduce(1, {:error, 1, "hello"})
    {:error, 1, "hello"}
  """
  def reduce(lvalue, rvalue) when is_integer(lvalue) and is_integer(rvalue) do
    Kernel.div(lvalue, rvalue)
  end

  def reduce(lvalue, rvalue) when is_float(lvalue) and is_integer(rvalue) do
    lvalue / rvalue
  end

  def reduce(lvalue, rvalue) when is_integer(lvalue) and is_float(rvalue) do
    lvalue / rvalue
  end

  def reduce({:error, line, msg}, _rvalue) do
    {:error, line, msg}
  end

  def reduce(_lvalue, {:error, line, msg}) do
    {:error, line, msg}
  end
end
