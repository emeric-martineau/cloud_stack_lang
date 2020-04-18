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
  def reduce({:error, line, msg}, _rvalue), do: {:error, line, msg}

  def reduce(_lvalue, {:error, line, msg}), do: {:error, line, msg}

  def reduce({:int, lvalue}, {:int, rvalue}), do: {:int, lvalue - rvalue}

  def reduce({:float, lvalue}, {:int, rvalue}), do: {:float, lvalue - rvalue}

  def reduce({:int, lvalue}, {:float, rvalue}), do: {:float, lvalue - rvalue}

  def reduce({:float, lvalue}, {:float, rvalue}), do: {:float, lvalue - rvalue}

  def reduce(lvalue, rvalue),
    do: {:error, "'-' operator not supported for #{inspect(lvalue)}, #{inspect(rvalue)}"}
end
