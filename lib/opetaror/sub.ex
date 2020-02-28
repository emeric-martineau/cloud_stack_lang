defmodule CloudStackLang.Operator.Sub do
  @moduledoc """
  This module contains all routine to perform sub operation.

  ## Examples

    iex> CloudStackLang.Operator.Sub.reduce(3, 1)
    2

    iex> CloudStackLang.Operator.Sub.reduce({:error, 1, "hello"}, 1)
    {:error, 1, "hello"}

    iex> CloudStackLang.Operator.Sub.reduce(1, {:error, 1, "hello"})
    {:error, 1, "hello"}
  """
  def reduce({:error, line, msg}, _rvalue) do
    {:error, line, msg}
  end

  def reduce(_lvalue, {:error, line, msg}) do
    {:error, line, msg}
  end

  def reduce(lvalue, rvalue) do
    lvalue - rvalue
  end
end
