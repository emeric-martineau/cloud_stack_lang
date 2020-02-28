defmodule CloudStackLang.Operator.Sub do
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
