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
defmodule CloudStackLang.Providers.AWS.DependencyManager do
  @moduledoc ~S"""
  This module generate a dependency map for a list of module.

  ## Examples

  """
  def generate_depends_on_properties(resource_properties) do
    props =
      generate_dependencies(resource_properties)
      |> List.flatten()
      |> Enum.uniq()

    case props do
      [] ->
        []

      [one_dependency] ->
        {:string, one_dependency}

      multi_dependencies ->
        multi_dependencies
        |> Enum.map(fn dep -> {:string, dep} end)
    end
  end

  defp generate_dependencies({:map, data}) do
    data
    |> Enum.flat_map(fn {_key, value} ->
      generate_dependencies(value)
    end)
    |> List.flatten()
  end

  defp generate_dependencies({:array, data}) do
    data
    |> Enum.flat_map(fn value ->
      generate_dependencies(value)
    end)
    |> List.flatten()
  end

  defp generate_dependencies({:module_fct, _name, args}), do: generate_dependencies(args)

  defp generate_dependencies({:atom, data}) do
    a =
      data
      |> Atom.to_string()
      |> Macro.camelize()

    [a]
  end

  defp generate_dependencies(_), do: []
end
