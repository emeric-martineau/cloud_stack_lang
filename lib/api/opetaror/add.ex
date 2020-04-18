#
# Copyright 2020 Cloud Stack Lang Contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
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
    {:error, 1, "hello"}

    iex> CloudStackLang.Operator.Add.reduce({:int, 1}, {:error, 1, "hello"})
    {:error, 1, "hello"}

    iex> CloudStackLang.Operator.Add.reduce({:int, 1}, {:string, "a"})
    {:string, "1a"}

    iex> CloudStackLang.Operator.Add.reduce({:string, "a"}, {:int, 1})
    {:string, "a1"}

    iex> CloudStackLang.Operator.Add.reduce({:float, 1.0}, {:string, "a"})
    {:string, "1.0a"}

    iex> CloudStackLang.Operator.Add.reduce({:string, "a"}, {:float, 1.0})
    {:string, "a1.0"}

    iex> CloudStackLang.Operator.Add.reduce({:string, "a"}, {:string, "b"})
    {:string, "ab"}

    iex> CloudStackLang.Operator.Add.reduce({:array, [ {:int, 1} ]}, {:array, [ {:int, 2}, {:int, 3} ]})
    {:array, [int: 1, int: 2, int: 3]}

    iex> CloudStackLang.Operator.Add.reduce({:map, %{ :a => {:int, 1}  }}, {:map, %{ :b => {:int, 2}, :c => {:int, 3} }})
    {:map, %{a: {:int, 1}, b: {:int, 2}, c: {:int, 3}}}
  """
  def reduce({:error, line, msg}, _rvalue), do: {:error, line, msg}

  def reduce(_lvalue, {:error, line, msg}), do: {:error, line, msg}

  def reduce({:int, lvalue}, {:int, rvalue}), do: {:int, lvalue + rvalue}

  def reduce({:float, lvalue}, {:int, rvalue}), do: {:float, lvalue + rvalue}

  def reduce({:int, lvalue}, {:float, rvalue}), do: {:float, lvalue + rvalue}

  def reduce({:float, lvalue}, {:float, rvalue}), do: {:float, lvalue + rvalue}

  def reduce({:int, lvalue}, {:string, rvalue}),
    do: {:string, Integer.to_string(lvalue) <> rvalue}

  def reduce({:float, lvalue}, {:string, rvalue}),
    do: {:string, Float.to_string(lvalue) <> rvalue}

  def reduce({:string, lvalue}, {:int, rvalue}),
    do: {:string, lvalue <> Integer.to_string(rvalue)}

  def reduce({:string, lvalue}, {:float, rvalue}),
    do: {:string, lvalue <> Float.to_string(rvalue)}

  def reduce({:string, lvalue}, {:string, rvalue}), do: {:string, lvalue <> rvalue}

  def reduce({:array, lvalue}, {:array, rvalue}), do: {:array, Enum.concat(lvalue, rvalue)}

  def reduce({:map, lvalue}, {:map, rvalue}), do: {:map, Map.merge(lvalue, rvalue)}

  def reduce(lvalue, rvalue),
    do: {:error, "'+' operator not supported for #{inspect(lvalue)}, #{inspect(rvalue)}"}
end
