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
defmodule CloudStackLang.Providers.AWS.Yaml.Mapping do
  @moduledoc ~S"""
  This module generate YAML stream for mapping.
  """

  def generate_aws_mapping([]), do: %{}

  # [
  #  {"MyMapName", ["AWS", "Map"],
  #   {:map,
  #    %{
  #      "RootKey" => {:map, %{"Key1" => {:string, "1"}, "Key2" => {:string, "2"}}}
  #    }}}
  # ]
  def generate_aws_mapping(aws_mapping) do
    mapping =
      aws_mapping
      |> Enum.map(fn {map_name, _type, map} -> {map_name, map} end)
      |> Map.new()

    %{"Mappings" => {:map, mapping}}
  end
end
