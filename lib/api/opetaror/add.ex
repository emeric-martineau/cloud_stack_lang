defmodule CloudStackLang.Operator.Add do
  @moduledoc """
  This module contains all routine to perform add operation.

  ## Examples

    iex> CloudStackLang.Operator.Add.reduce({:int, 1}, {:int, 1})
    {:int, 2}

    iex> CloudStackLang.Operator.Add.reduce({:float, 1.0}, {:int, 1})
    {:float, 2.0}

    iex> CloudStackLang.Operator.Add.reduce({:int, 1}, {:float, 1.0})
    {:float, 2.0}

    iex> CloudStackLang.Operator.Add.reduce({:float, 1.0}, {:float, 1.0})
    {:float, 2.0}

    iex> CloudStackLang.Operator.Add.reduce({:error, 1, "hello"}, {:int, 1})
    {:error, "hello"}

    iex> CloudStackLang.Operator.Add.reduce({:int, 1}, {:error, 1, "hello"})
    {:error, "hello"}

    iex> CloudStackLang.Operator.Add.reduce({:int, 1}, {:string, "coucou"})
    {:error, "'+' operator not supported for {:int, 1}, {:string, \\"coucou\\"}"}

    iex> CloudStackLang.Operator.Add.reduce({:string, "coucou"}, {:int, 1})
    {:error, "'+' operator not supported for {:string, \\"coucou\\"}, {:int, 1}"}

    iex> CloudStackLang.Operator.Add.reduce({:float, 1}, {:string, "coucou"})
    {:error, "'+' operator not supported for {:float, 1}, {:string, \\"coucou\\"}"}

    iex> CloudStackLang.Operator.Add.reduce({:string, "coucou"}, {:float, 1})
    {:error, "'+' operator not supported for {:string, \\"coucou\\"}, {:float, 1}"}
  """
  def reduce({:error, _line, msg}, _rvalue) do
    {:error, msg}
  end

  def reduce(_lvalue, {:error, _line, msg}) do
    {:error, msg}
  end

  def reduce({:int, lvalue}, {:int, rvalue}) do
    {:int, lvalue + rvalue}
  end

  def reduce({:float, lvalue}, {:int, rvalue}) do
    {:float, lvalue + rvalue}
  end

  def reduce({:int, lvalue}, {:float, rvalue}) do
    {:float, lvalue + rvalue}
  end

  def reduce({:float, lvalue}, {:float, rvalue}) do
    {:float, lvalue + rvalue}
  end

  def reduce(lvalue, rvalue) do
    {:error, "'+' operator not supported for #{inspect lvalue}, #{inspect rvalue}"}
  end

  # TODO support for string, array and map
end
