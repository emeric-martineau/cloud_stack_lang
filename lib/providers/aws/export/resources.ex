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
defmodule CloudStackLang.Providers.AWS.Yaml.Resources do
  @moduledoc ~S"""
  This module generate YAML stream for resources.
  """
  alias CloudStackLang.Providers.AWS.DependencyManager

  # Generate all resource for AWS.
  # Input type is array.
  def generate_aws_resources_map(aws_resources),
    do:
      aws_resources
      |> Enum.map(&generate_one_aws_resources/1)
      |> Map.new()

  defp generate_one_aws_resources({resource_name, namespace, resource_properties}) do
    [prefixe_ns, _domain | tail] = namespace

    # Remove "Resource" and generate type
    resource_type =
      [prefixe_ns | tail]
      |> Enum.join("::")

    # Extract resource attributs
    {:map, props} = resource_properties

    # By using :atom, depends on can by generate automatically include `depends_on` properties
    depends_on = DependencyManager.generate_depends_on_properties(resource_properties)
    props = Map.delete(props, "DependsOn")

    {props, creation_policy} = map_get_and_delete(props, "CreationPolicy")
    {props, update_policy} = map_get_and_delete(props, "UpdatePolicy")
    {props, deletion_policy} = map_get_and_delete(props, "DeletionPolicy")
    {props, update_replace_policy} = map_get_and_delete(props, "UpdateReplacePolicy")
    {props, metadata} = map_get_and_delete(props, "Metadata")

    # Create AWS resource attributs in map
    resource_attributs =
      %{
        "Type" => {:string, resource_type}
      }
      |> add_ressource_attribut_if_not_empty("DependsOn", depends_on)
      |> add_ressource_attribut_if_not_empty("Properties", props)
      |> add_ressource_attribut_if_not_empty("CreationPolicy", creation_policy)
      |> add_ressource_attribut_if_not_empty("UpdatePolicy", update_policy)
      |> add_ressource_attribut_if_not_empty("DeletionPolicy", deletion_policy)
      |> add_ressource_attribut_if_not_empty("UpdateReplacePolicy", update_replace_policy)
      |> add_ressource_attribut_if_not_empty("Metadata", metadata)

    {
      resource_name,
      {:map, resource_attributs}
    }
  end

  defp add_ressource_attribut_if_not_empty(map, _key, []), do: map

  defp add_ressource_attribut_if_not_empty(map, key, data) when is_list(data),
    do: Map.merge(map, %{key => {:array, data}})

  defp add_ressource_attribut_if_not_empty(map, _key, data)
       when is_map(data) and map_size(data) == 0,
       do: map

  defp add_ressource_attribut_if_not_empty(map, key, data) when is_map(data),
    do: Map.merge(map, %{key => {:map, data}})

  defp add_ressource_attribut_if_not_empty(map, _key, nil), do: map

  # Not a map or list
  defp add_ressource_attribut_if_not_empty(map, key, data), do: Map.merge(map, %{key => data})

  # Get value and delete it.
  # return {map, value}
  defp map_get_and_delete(map, key) do
    value = Map.get(map, key, nil)
    new_map = Map.delete(map, key)

    {new_map, value}
  end
end
