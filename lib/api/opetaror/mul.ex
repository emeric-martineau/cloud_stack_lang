defmodule CloudStackLang.Operator.Mul do
  @moduledoc """
  This module contains all routine to perform mul operation.

  ## Examples

    iex> CloudStackLang.Operator.Mul.reduce({:int, 2}, {:int, 2})
    {:int, 4}

    iex> CloudStackLang.Operator.Mul.reduce({:float, 2.0}, {:int, 2})
    {:float, 4.0}

    iex> CloudStackLang.Operator.Mul.reduce({:int, 2}, {:float, 2.0})
    {:float, 4.0}

    iex> CloudStackLang.Operator.Mul.reduce({:int, 2.0}, {:float, 2.0})
    {:float, 4.0}

    iex> CloudStackLang.Operator.Mul.reduce({:error, 1, "hello"}, 1)
    {:error, "hello"}

    iex> CloudStackLang.Operator.Mul.reduce(1, {:error, 1, "hello"})
    {:error, "hello"}
  """
  def reduce({:error, _line, msg}, _rvalue) do
    {:error, msg}
  end

  def reduce(_lvalue, {:error, _line, msg}) do
    {:error, msg}
  end

  def reduce({:int, lvalue}, {:int, rvalue}) do
    {:int, lvalue * rvalue}
  end

  def reduce({:float, lvalue}, {:int, rvalue}) do
    {:float, lvalue * rvalue}
  end

  def reduce({:int, lvalue}, {:float, rvalue}) do
    {:float, lvalue * rvalue}
  end

  def reduce({:float, lvalue}, {:float, rvalue}) do
    {:float, lvalue * rvalue}
  end

  def reduce(lvalue, rvalue) do
    {:error, "'*' operator not supported for #{inspect lvalue}, #{inspect rvalue}"}
  end
end
