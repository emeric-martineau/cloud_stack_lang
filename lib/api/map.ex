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
defmodule CloudStackLang.Map do
  @moduledoc """
  This module contains all routine to help access to map value with key.

    ## Examples

      iex> CloudStackLang.Map.reduce([{:string, 1, "c"}], {:map, %{"c" => {:int, 1}}})
      {:int, 1}

      iex> CloudStackLang.Map.reduce([{:string, 1, "c"}], nil)
      {:error, 1, "Trying get a value with key 'c' on nil value"}

      iex> CloudStackLang.Map.reduce([{:string, 1, "c"}], 1)
      {:error, 1, "Trying get a value with key 'c' on non-map value"}
  """

  def reduce(access_keys, {:map, state}) do
    [first_key | keys] = access_keys
    {_type, _line, key} = first_key

    reduce(keys, state[key])
  end

  def reduce(access_keys, {:array, state}) do
    [first_key | keys] = access_keys
    {_type, line, key} = first_key

    case key < length(state) do
      true -> reduce(keys, Enum.at(state, key))
      false -> {:error, line, "Index '#{key}' is out of range (#{length(state)} items in array)"}
    end
  end

  def reduce(access_keys, nil) do
    [first_key | _keys] = access_keys
    {_type, line, key} = first_key

    {:error, line, "Trying get a value with key '#{key}' on nil value"}
  end

  def reduce([], state), do: state

  def reduce(access_keys, _state) do
    [first_key | _keys] = access_keys
    {_type, line, key} = first_key

    {:error, line, "Trying get a value with key '#{key}' on non-map value"}
  end
end
