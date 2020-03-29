defmodule CloudStackLang.Operator.Exp do
  @moduledoc """
  This module contains all routine to perform add operation.

  ## Examples

    iex> CloudStackLang.Operator.Exp.reduce({:int, 2}, {:int, 0})
    {:int, 1}

    iex> CloudStackLang.Operator.Exp.reduce({:int, 2}, {:int, 2})
    {:int, 4}

    iex> CloudStackLang.Operator.Exp.reduce({:float, 2.8}, {:int, 2.9})
    {:float, 19.80424502306346}

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

  def reduce({:int, lvalue}, {:int, rvalue}) do
    {:int, Math.pow(lvalue, rvalue)}
  end

  def reduce({:float, lvalue}, {:int, rvalue}) do
    {:float, Math.pow(lvalue, rvalue)}
  end

  def reduce({:int, lvalue}, {:float, rvalue}) do
    {:float, Math.pow(lvalue, rvalue)}
  end

  def reduce(lvalue, rvalue) do
    {:error, "'^' operator not supported for #{inspect(lvalue)}, #{inspect(rvalue)}"}
  end
end
