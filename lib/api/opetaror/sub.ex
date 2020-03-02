defmodule CloudStackLang.Operator.Sub do
  @moduledoc """
  This module contains all routine to perform sub operation.

  ## Examples

    iex> CloudStackLang.Operator.Sub.reduce({:int, 3}, {:int, 1})
    {:int, 2}

    iex> CloudStackLang.Operator.Sub.reduce({:float, 3.0}, {:int, 1})
    {:float, 2.0}

    iex> CloudStackLang.Operator.Sub.reduce({:int, 3}, {:float, 1})
    {:float, 2}

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

  def reduce({:int, lvalue}, {:int, rvalue}) do
    {:int, lvalue - rvalue}
  end

  def reduce({:float, lvalue}, {:int, rvalue}) do
    {:float, lvalue - rvalue}
  end
  def reduce({:int, lvalue}, {:float, rvalue}) do
    {:float, lvalue - rvalue}
  end

  def reduce({:float, lvalue}, {:float, rvalue}) do
    {:float, lvalue - rvalue}
  end

  def reduce(lvalue, rvalue) do
    {:error, "'-' operator not supported for #{inspect lvalue}, #{inspect rvalue}"}
  end
end
