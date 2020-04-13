defmodule CloudStackLang.Providers.AWS.DependencyManager do
  @moduledoc ~S"""
  This module generate a dependency map for a list of module.

  ## Examples

  """

  def gen(properties) do
    generate_dependencies(properties)
    |> List.flatten()
    |> Enum.uniq()
  end

  defp generate_dependencies({:map, data}) do
    data
    |> Enum.flat_map(fn {_key, value} ->
      case value do
        {:array, _data} -> [generate_dependencies(value)]
        {:map, _data} -> [generate_dependencies(value)]
        {:atom, _data} -> [generate_dependencies(value)]
        _ -> []
      end
    end)
    |> List.flatten()
  end

  defp generate_dependencies({:array, data}) do
    data
    |> Enum.flat_map(fn value ->
      case value do
        {:array, _data} -> [generate_dependencies(value)]
        {:map, _data} -> [generate_dependencies(value)]
        {:atom, _data} -> [generate_dependencies(value)]
        _ -> []
      end
    end)
    |> List.flatten()
  end

  defp generate_dependencies({:module_fct, _name, args}),
    do: generate_dependencies({:array, args})

  defp generate_dependencies({:atom, data}) do
    data
    |> Atom.to_string()
    |> Macro.camelize()
  end
end
