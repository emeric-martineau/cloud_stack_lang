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
