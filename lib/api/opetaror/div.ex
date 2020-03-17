defmodule CloudStackLang.Operator.Div do
  @moduledoc """
  This module contains all routine to perform sub operation.

  ## Examples

    iex> CloudStackLang.Operator.Div.reduce({:int, 6}, {:int, 2})
    {:int, 3}

    iex> CloudStackLang.Operator.Div.reduce({:float, 8.0}, {:int, 2})
    {:float, 4.0}

    iex> CloudStackLang.Operator.Div.reduce({:int, 8}, {:float, 2.0})
    {:float, 4.0}

    iex> CloudStackLang.Operator.Div.reduce({:float, 8.0}, {:float, 2.0})
    {:float, 4.0}

    iex> CloudStackLang.Operator.Div.reduce({:error, 1, "hello"}, 1)
    {:error, 1, "hello"}

    iex> CloudStackLang.Operator.Div.reduce({:int, 1}, {:error, 1, "hello"})
    {:error, 1, "hello"}

    iex> CloudStackLang.Operator.Div.reduce({:int, 3}, {:float, 2.0})
    {:float, 1.5}
  """
  def reduce({:int, lvalue}, {:int, rvalue}) do
    {:int, Kernel.div(lvalue, rvalue)}
  end

  def reduce({:float, lvalue}, {:int, rvalue}) do
    {:float, lvalue / rvalue}
  end

  def reduce({:int, lvalue}, {:float, rvalue}) do
    {:float, lvalue / rvalue}
  end

  def reduce({:float, lvalue}, {:float, rvalue}) do
    {:float, lvalue / rvalue}
  end

  def reduce({:error, line, msg}, _rvalue) do
    {:error, line, msg}
  end

  def reduce(_lvalue, {:error, line, msg}) do
    {:error, line, msg}
  end

  def reduce(lvalue, rvalue) do
    {:error, "'/' operator not supported for #{inspect lvalue}, #{inspect rvalue}"}
  end
end
