defmodule CloudStackLang.Operator.Div do
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
