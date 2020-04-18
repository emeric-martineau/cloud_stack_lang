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
defmodule CloudStackLang.Providers.AWS.Yaml do
  @moduledoc ~S"""
  This module generate YAML stream.

  ## Examples
    iex> module = %{"AvailabilityZone" => {:string, "eu-west-1a"}, "ImageId" => {:string, "ami-0713f98de93617bb4"}, "InstanceType" => {:string, "t2.micro"}}
    ...> CloudStackLang.Providers.AWS.Yaml.gen([{"YouKnowMyName", ["AWS", "Resource", "TheType"], {:map, module}}])
    "Resources:\n  YouKnowMyName:\n    Properties:\n      AvailabilityZone: eu-west-1a\n      ImageId: ami-0713f98de93617bb4\n      InstanceType: t2.micro\n    Type: AWS::TheType"

    iex> module = %{"a" => {:string, "SSH and HTTP"}, "b" => {:array, [map: %{"c" => {:string, "0.0.0.0/0"}, "d" => {:int, 22}, "e" => {:string, "tcp"}, "f" => {:int, 22}}, map: %{"g" => {:string, "0.0.0.0/0"}, "h" => {:int, 80}, "i" => {:string, "tcp"}, "j" => {:int, 80}}]}}
    ...> CloudStackLang.Providers.AWS.Yaml.gen([{"YouKnowMyName", ["AWS", "Resource", "TheType"], {:map, module}}])
    "Resources:\n  YouKnowMyName:\n    Properties:\n      a: SSH and HTTP\n      b:\n        - \n          c: 0.0.0.0/0\n          d: 22\n          e: tcp\n          f: 22\n        - \n          g: 0.0.0.0/0\n          h: 80\n          i: tcp\n          j: 80\n    Type: AWS::TheType"

    iex> module = %{"a" => {:map, %{"a" => {:int, 1}, "b" => {:int, 2}, "c" => {:array, [{:int, 0}, {:int, 1}]}}}, "b" => {:string, "hello"}}
    ...> CloudStackLang.Providers.AWS.Yaml.gen([{"YouKnowMyName", ["AWS", "Resource", "TheType"], {:map, module}}])
    "Resources:\n  YouKnowMyName:\n    Properties:\n      a:\n        a: 1\n        b: 2\n        c:\n          - 0\n          - 1\n      b: hello\n    Type: AWS::TheType"

    iex> module = %{"a" => {:map, %{"a" => {:int, 1}, "b" => {:int, 2}, "c" => {:array, [{:int, 0}, {:int, 1}]}}}, "b" => {:atom, :hello}}
    ...> CloudStackLang.Providers.AWS.Yaml.gen([{"YouKnowMyName", ["AWS", "Resource", "TheType"], {:map, module}}])
    "Resources:\n  YouKnowMyName:\n    DependsOn: Hello\n    Properties:\n      a:\n        a: 1\n        b: 2\n        c:\n          - 0\n          - 1\n      b: !Ref Hello\n    Type: AWS::TheType"

    iex> module = %{"a" => {:string, ":Thing"}}
    ...> CloudStackLang.Providers.AWS.Yaml.gen([{"YouKnowMyName", ["AWS", "Resource", "TheType"], {:map, module}}])
    "Resources:\n  YouKnowMyName:\n    Properties:\n      a: \":Thing\"\n    Type: AWS::TheType"

    iex> module = %{"a" => {:string, " Thing"}}
    ...> CloudStackLang.Providers.AWS.Yaml.gen([{"YouKnowMyName", ["AWS", "Resource", "TheType"], {:map, module}}])
    "Resources:\n  YouKnowMyName:\n    Properties:\n      a: \" Thing\"\n    Type: AWS::TheType"

    iex> module = %{"a" => {:string, "Thing\t"}}
    ...> CloudStackLang.Providers.AWS.Yaml.gen([{"YouKnowMyName", ["AWS", "Resource", "TheType"], {:map, module}}])
    "Resources:\n  YouKnowMyName:\n    Properties:\n      a: \"Thing\t\"\n    Type: AWS::TheType"

    iex> module = %{"a" => {:string, "Thing\nEarly"}}
    ...> CloudStackLang.Providers.AWS.Yaml.gen([{"YouKnowMyName", ["AWS", "Resource", "TheType"], {:map, module}}])
    "Resources:\n  YouKnowMyName:\n    Properties:\n      a: \"Thing\\nEarly\"\n    Type: AWS::TheType"

    iex> module = %{"a" => {:string, ""}}
    ...> CloudStackLang.Providers.AWS.Yaml.gen([{"YouKnowMyName", ["AWS", "Resource", "TheType"], {:map, module}}])
    "Resources:\n  YouKnowMyName:\n    Properties:\n      a: \"\"\n    Type: AWS::TheType"

  """
  use CloudStackLang.Export.Yaml
  alias CloudStackLang.Providers.AWS.Yaml.Resources
  alias CloudStackLang.Providers.AWS.Yaml.Mapping
  alias CloudStackLang.Providers.AWS.Yaml.Globals

  def gen(modules) do
    yaml_aws_resources =
      modules
      |> filter_by_type("Resource")
      |> Resources.generate_aws_resources_map()

    # TODO check dependencies if found in map

    # AWS::Stack
    yaml_aws_global =
      modules
      |> filter_by_type("Stack")
      |> Globals.generate_aws_global_map()

    # AWS::Map
    yaml_aws_mapping =
      modules
      |> filter_by_type("Map")
      |> Mapping.generate_aws_mapping()

    data =
      yaml_aws_global
      |> Map.merge(yaml_aws_mapping)
      |> Map.merge(%{
        "Resources" => {:map, yaml_aws_resources}
      })

    generate({:map, data}, "")
  end

  # Module start always by provider, then type of module.
  # E.g. AWS::Resource::xxxxx
  defp filter_by_type(aws_module, type),
    do:
      aws_module
      |> Enum.filter(fn {_module_name, namespace, _module_properties} ->
        [_prefixe_ns, domain | _tail] = namespace
        domain == type
      end)

  ##################################### Ref ###################################
  defp generate({:atom, data}, _indent) do
    ref =
      data
      |> Atom.to_string()
      |> Macro.camelize()

    "!Ref #{ref}"
  end

  defp generate({:module_fct, "ref", {:string, item}}, _indent) do
    "!Ref #{item}"
  end

  #################################### Base64 #################################
  defp generate({:module_fct, "base64", {:string, item}}, indent) do
    item = generate({:string, item}, "")
    "\n#{indent}Fn::Base64: #{item}"
  end

  defp generate({:module_fct, "base64", {:module_fct, fct, data}}, indent) do
    result = generate({:module_fct, fct, data}, "#{indent}  ")
    "\n#{indent}Fn::Base64: #{result}"
  end

  #################################### Cidr ###################################
  defp generate(
         {:module_fct, "cidr", {:array, [{:string, ip_block}, {:int, count}, {:int, cidr_bits}]}},
         indent
       ) do
    result =
      generate({:array, [{:string, ip_block}, {:int, count}, {:int, cidr_bits}]}, "#{indent}  ")

    "\n#{indent}Fn::Cidr:\n#{result}"
  end

  defp generate(
         {:module_fct, "cidr",
          {:array, [{:module_fct, fct, data}, {:int, count}, {:int, cidr_bits}]}},
         indent
       ) do
    result =
      generate(
        {:array, [{:module_fct, fct, data}, {:int, count}, {:int, cidr_bits}]},
        "#{indent}  "
      )

    "\n#{indent}Fn::Cidr:\n#{result}"
  end

  #################################### GetAZs #################################
  defp generate({:module_fct, "get_azs", {:string, item}}, indent) do
    item = generate({:string, item}, "")
    "\n#{indent}Fn::GetAZs: #{item}"
  end

  defp generate({:module_fct, "get_azs", {:module_fct, fct, data}}, indent) do
    result = generate({:module_fct, fct, data}, "#{indent}  ")
    "\n#{indent}Fn::GetAZs: #{result}"
  end

  #################################### Select #################################
  defp generate({:module_fct, "select", {:array, [{:int, index}, {:array, data}]}}, indent) do
    result = generate({:array, [{:int, index}, {:array, data}]}, "#{indent}  ")

    "\n#{indent}Fn::Select:\n#{result}"
  end

  defp generate(
         {:module_fct, "select", {:array, [{:int, index}, {:module_fct, fct, data}]}},
         indent
       ) do
    result = generate({:array, [{:int, index}, {:module_fct, fct, data}]}, "#{indent}  ")

    "\n#{indent}Fn::Select:\n#{result}"
  end

  #################################### Split ##################################
  defp generate({:module_fct, "split", {:array, [{:string, delimiter}, {:string, data}]}}, indent) do
    result = generate({:array, [{:string, delimiter}, {:string, data}]}, "#{indent}  ")

    "\n#{indent}Fn::Split:\n#{result}"
  end

  defp generate(
         {:module_fct, "split", {:array, [{:string, delimiter}, {:module_fct, fct, data}]}},
         indent
       ) do
    result = generate({:array, [{:string, delimiter}, {:module_fct, fct, data}]}, "#{indent}  ")

    "\n#{indent}Fn::Split:\n#{result}"
  end

  #################################### Join ###################################
  defp generate({:module_fct, "join", {:array, [{:string, delimiter}, {:array, data}]}}, indent) do
    result = generate({:array, [{:string, delimiter}, {:array, data}]}, "#{indent}  ")

    "\n#{indent}Fn::Join:\n#{result}"
  end

  #################################### Transform ##############################
  defp generate(
         {:module_fct, "transform", {:array, [{:string, macro_name}, {:map, data}]}},
         indent
       ) do
    name = generate({:string, macro_name}, "")
    result = generate({:map, data}, "#{indent}    ")

    "\n#{indent}Fn::Transform:\n#{indent}  Name: #{name}\n#{indent}  Parameters:\n#{result}"
  end

  ###################################### GetAtt ###############################
  defp generate(
         {:module_fct, "get_att",
          {:array, [{:atom, logical_name_of_resource}, {:string, attribute_name}]}},
         indent
       ) do
    name =
      logical_name_of_resource
      |> Atom.to_string()
      |> Macro.camelize()

    result = generate({:array, [{:string, name}, {:string, attribute_name}]}, "#{indent}  ")

    "\n#{indent}Fn::GetAtt:\n#{result}"
  end

  defp generate(
         {:module_fct, "get_att",
          {:array, [{:string, logical_name_of_resource}, {:string, attribute_name}]}},
         indent
       ) do
    result =
      generate(
        {:array, [{:string, logical_name_of_resource}, {:string, attribute_name}]},
        "#{indent}  "
      )

    "\n#{indent}Fn::GetAtt:\n#{result}"
  end

  #################################### Sub ###################################
  defp generate({:module_fct, "sub", {:array, data}}, indent) do
    result = generate({:array, data}, "#{indent}  ")

    "\n#{indent}Fn::Sub:\n#{result}"
  end

  #################################### FindInMap ###################################
  defp generate({:module_fct, "find_in_map", {:array, data}}, indent) do
    result = generate({:array, data}, "#{indent}  ")

    "\n#{indent}Fn::FindInMap:\n#{result}"
  end

  # TODO check atom to make automatic depondson, check also GetAttr
  # TODO allow ref to AWS::xxx variable
  # Fn::GetAZs:
  #   Ref: "AWS::Region"
  #
  # ImageId: !FindInMap
  #        - RegionMap
  #        - !Ref 'AWS::Region'
  #        - HVM64
end
