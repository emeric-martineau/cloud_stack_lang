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
defmodule CloudStackLang.Number do
  @moduledoc """
  This module contains all routine to perform number operation.
  """

  @doc ~S"""
  Returns integer form string. Must be valid string.

  ## Examples

      iex> CloudStackLang.Number.from_hexa('0xfA')
      {:int, 250}
  """
  def from_hexa(value) do
    {number, _} =
      value
      |> List.to_string()
      |> String.slice(2..-1)
      |> String.downcase()
      |> Integer.parse(16)

    {:int, number}
  end

  @doc ~S"""
  Returns integer form string. Must be valid string.

  ## Examples

      iex> CloudStackLang.Number.from_octal('0o437')
      {:int, 287}
  """
  def from_octal(value) do
    {number, _} =
      value
      |> List.to_string()
      |> String.slice(2..-1)
      |> Integer.parse(8)

    {:int, number}
  end
end
