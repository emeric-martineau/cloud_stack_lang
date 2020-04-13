defmodule CloudStackLang.Core.Module do
  @moduledoc ~S"""
    This module contain some functions for core process module.

    iex> CloudStackLang.Core.Module.convert_list_of_name_to_list_of_string([{:name, 1, 'a'}, {:name, 1, 'b'}, {:name, 1, 'c'}])
    ["a", "b", "c"]

    iex> CloudStackLang.Core.Module.convert_all_map_key_to_camelcase({:map, %{"camel_case1" => {:map, %{"camel_case2" => {:array, [{:map, %{"camel_case3" => 1}}]}}}}})
    {:map, %{"CamelCase1" => {:map, %{"CamelCase2" => {:array, [map: %{"CamelCase3" => 1}]}}}}}
  """
  alias CloudStackLang.Core.Util

  def convert_list_of_name_to_list_of_string(list),
    do:
      list
      |> Enum.map(fn {:name, _line, name} -> name end)
      |> Enum.map(&List.to_string/1)

  def convert_all_map_key_to_camelcase(item) when is_map(item),
    do:
      item
      |> Map.new(fn {key, value} ->
        {Macro.camelize(key), convert_all_map_key_to_camelcase(value)}
      end)

  def convert_all_map_key_to_camelcase({:array, item}) do
    new_item =
      item
      |> Enum.map(fn i -> convert_all_map_key_to_camelcase(i) end)

    {:array, new_item}
  end

  def convert_all_map_key_to_camelcase({:map, item}) do
    new_item =
      item
      |> Map.new(fn {key, value} ->
        {Macro.camelize(key), convert_all_map_key_to_camelcase(value)}
      end)

    {:map, new_item}
  end

  def convert_all_map_key_to_camelcase(item), do: item

  def convert_module_name(name, reduce_fct),
    do:
      name
      |> reduce_fct.()
      |> Util.extract_value()
      |> Atom.to_string()
      |> Macro.camelize()
end
