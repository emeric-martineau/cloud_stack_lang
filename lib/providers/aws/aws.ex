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
defmodule CloudStackLang.Providers.AWS do
  @moduledoc ~S"""
  This module contain the AWS provider.
  """
  alias CloudStackLang.Providers.AWS.Yaml

  def prefix(), do: "AWS"

  def name(), do: "aws"

  def export_to(modules, format) do
    case format do
      "yaml" -> Yaml.gen(modules)
      v -> {:error, "Unsupported format #{v}"}
    end
  end

  # TODO : GetAtt, FindInMap, ImportValue can have variable form like 'modules.my_module.attribut'
  def modules_functions(),
    do: %{
      :ref => {:manager, &aws_fct_manager/2},
      :base64 => {:manager, &aws_fct_manager/2},
      :cidr => {:manager, &aws_fct_manager/2},
      :find_in_map => {:manager, &aws_fct_manager/2},
      # Shortcut of find_in_map
      :map => {:manager, &aws_fct_manager/2},
      :get_att => {:manager, &aws_fct_manager/2},
      # Shortcut of get_att
      :module => {:manager, &aws_fct_manager/2},
      :get_azs => {:manager, &aws_fct_manager/2},
      # TODO
      :import_value => {:manager, &aws_fct_manager/2},
      :join => {:manager, &aws_fct_manager/2},
      :select => {:manager, &aws_fct_manager/2},
      :split => {:manager, &aws_fct_manager/2},
      :sub => {:manager, &aws_fct_manager/2},
      :transform => {:manager, &aws_fct_manager/2},
      :name => {:manager, &aws_fct_manager/2}
    }

  ####################################### Ref #################################
  defp aws_fct_manager([{:name, _line, 'ref'}], [{:string, item}]),
    do: {:module_fct, "ref", {:string, item}}

  defp aws_fct_manager([{:name, _line, 'ref'}], [{:atom, item}]), do: {:atom, item}

  defp aws_fct_manager([{:name, _line, 'ref'}], [{type, _item}]),
    do: base_argument("ref", 0, "':atom' or ':string'", type)

  defp aws_fct_manager([{:name, _line, 'ref'}], args),
    do: wrong_argument("ref", 1, args)

  #################################### Base64 #################################
  defp aws_fct_manager([{:name, _line, 'base64'}], [{:string, item}]),
    do: {:module_fct, "base64", {:string, item}}

  defp aws_fct_manager([{:name, _line, 'base64'}], [{:module_fct, fct, data}]),
    do: {:module_fct, "base64", {:module_fct, fct, data}}

  defp aws_fct_manager([{:name, _line, 'base64'}], [{type, _item}]),
    do: base_argument("base64", 0, "':string' or another function", type)

  defp aws_fct_manager([{:name, _line, 'base64'}], args),
    do: wrong_argument("base64", 1, args)

  #################################### Cidr ###################################
  defp aws_fct_manager([{:name, _line, 'cidr'}], [
         {:string, ip_block},
         {:int, count},
         {:int, cidr_bits}
       ]) do
    {:module_fct, "cidr", {:array, [{:string, ip_block}, {:int, count}, {:int, cidr_bits}]}}
  end

  defp aws_fct_manager([{:name, _line, 'cidr'}], [
         {:module_fct, fct, data},
         {:int, count},
         {:int, cidr_bits}
       ]) do
    {:module_fct, "cidr", {:array, [{:module_fct, fct, data}, {:int, count}, {:int, cidr_bits}]}}
  end

  defp aws_fct_manager([{:name, _line, 'cidr'}], [_, _, _]),
    do:
      {:error,
       "Bad type argument for 'cidr'. Waiting ([':string' or function call], ':int', ':int')"}

  defp aws_fct_manager([{:name, _line, 'cidr'}], args),
    do: wrong_argument("cidr", 3, args)

  #################################### GetAZs #################################
  defp aws_fct_manager([{:name, _line, 'get_azs'}], []),
    do: {:module_fct, "get_azs", {:string, ""}}

  defp aws_fct_manager([{:name, _line, 'get_azs'}], [{:string, item}]),
    do: {:module_fct, "get_azs", {:string, item}}

  defp aws_fct_manager([{:name, _line, 'get_azs'}], [{:module_fct, fct, data}]),
    do: {:module_fct, "get_azs", {:module_fct, fct, data}}

  defp aws_fct_manager([{:name, _line, 'get_azs'}], [{type, _item}]),
    do: base_argument("get_azs", 0, "':string' or another function", type)

  defp aws_fct_manager([{:name, _line, 'get_azs'}], args),
    do: wrong_argument("get_azs", 1, args)

  #################################### Select #################################
  defp aws_fct_manager([{:name, _line, 'select'}], [{:int, index}, {:module_fct, fct, data}]),
    do: {:module_fct, "select", {:array, [{:int, index}, {:module_fct, fct, data}]}}

  defp aws_fct_manager([{:name, _line, 'select'}], [{:int, index}, {:array, data}]),
    do: {:module_fct, "select", {:array, [{:int, index}, {:array, data}]}}

  defp aws_fct_manager([{:name, _line, 'select'}], [_, _]),
    do: {:error, "Bad type argument for 'select'. Waiting (':int', [':array' or function call])"}

  defp aws_fct_manager([{:name, _line, 'select'}], args),
    do: wrong_argument("select", 2, args)

  #################################### Split #################################
  defp aws_fct_manager([{:name, _line, 'split'}], [{:string, delimiter}, {:string, data}]),
    do: {:module_fct, "split", {:array, [{:string, delimiter}, {:string, data}]}}

  defp aws_fct_manager([{:name, _line, 'split'}], [{:string, delimiter}, {:module_fct, fct, data}]),
       do: {:module_fct, "split", {:array, [{:string, delimiter}, {:module_fct, fct, data}]}}

  defp aws_fct_manager([{:name, _line, 'split'}], [_, _]),
    do: {:error, "Bad type argument for 'split'. Waiting (':string', function call)"}

  defp aws_fct_manager([{:name, _line, 'split'}], args),
    do: wrong_argument("split", 2, args)

  #################################### Join #################################
  defp aws_fct_manager([{:name, _line, 'join'}], [{:string, delimiter}, {:array, data}]),
    do: {:module_fct, "join", {:array, [{:string, delimiter}, {:array, data}]}}

  defp aws_fct_manager([{:name, _line, 'join'}], [_, _]),
    do: {:error, "Bad type argument for 'join'. Waiting (':string', ':array')"}

  defp aws_fct_manager([{:name, _line, 'join'}], args),
    do: wrong_argument("join", 2, args)

  #################################### Transform #################################
  defp aws_fct_manager([{:name, _line, 'transform'}], [{:string, macro_name}, {:map, data}]),
    do: {:module_fct, "transform", {:array, [{:string, macro_name}, {:map, data}]}}

  defp aws_fct_manager([{:name, _line, 'transform'}], [_, _]),
    do: {:error, "Bad type argument for 'transform'. Waiting (':string', ':map')"}

  defp aws_fct_manager([{:name, _line, 'transform'}], args),
    do: wrong_argument("transform", 2, args)

  #################################### GetAtt #################################
  defp aws_fct_manager([{:name, _line, 'get_att'}], [
         {:string, logical_name_of_resource},
         {:string, attribute_name}
       ]),
       do:
         {:module_fct, "get_att",
          {:array, [{:string, logical_name_of_resource}, {:string, attribute_name}]}}

  defp aws_fct_manager([{:name, _line, 'get_att'}], [
         {:atom, logical_name_of_resource},
         {:string, attribute_name}
       ]),
       do:
         {:module_fct, "get_att",
          {:array, [{:atom, logical_name_of_resource}, {:string, attribute_name}]}}

  defp aws_fct_manager([{:name, _line, 'module'} | [module_name | properties]], []) do
    {:name, _line, m_name} = module_name

    logical_name_of_resource =
      m_name
      |> List.to_atom()

    attribute_name =
      properties
      |> Enum.map(fn {:name, _line, property_name} ->
        convert_list_to_name(property_name)
      end)
      |> Enum.join(".")

    {:module_fct, "get_att",
     {:array, [{:atom, logical_name_of_resource}, {:string, attribute_name}]}}
  end

  defp aws_fct_manager([{:name, _line, 'get_att'}], [_, _]),
    do: {:error, "Bad type argument for 'get_att'. Waiting ([':string' or ':atom'], ':string')"}

  defp aws_fct_manager([{:name, _line, 'get_att'}], args),
    do: wrong_argument("get_att", 2, args)

  ####################################### Sub #################################
  defp aws_fct_manager([{:name, _line, 'sub'}], [{:string, pattern}]),
    do: {:module_fct, "sub", {:array, [{:string, pattern}]}}

  defp aws_fct_manager([{:name, _line, 'sub'}], [{:string, pattern}, {:map, data}]),
    do: {:module_fct, "sub", {:array, [{:string, pattern}, {:map, data}]}}

  defp aws_fct_manager([{:name, _line, 'sub'}], [_, _]),
    do: {:error, "Bad type argument for 'sub'. Waiting (':string' [ , ':map'])"}

  defp aws_fct_manager([{:name, _line, 'sub'}], args),
    do: wrong_argument("sub", "1 or 2", args)

  ####################################### name() #################################
  defp aws_fct_manager([{:name, _line, 'name'}], [{:atom, item}]),
    do: convert_atom_to_csl_string(item)

  defp aws_fct_manager([{:name, _line, 'name'}], [{type, _item}]),
    do: base_argument("name", 0, "':atom'", type)

  defp aws_fct_manager([{:name, _line, 'name'}], args),
    do: wrong_argument("name", 1, args)

  ####################################### FindInMap #################################
  defp aws_fct_manager([{:name, _line, 'find_in_map'}], [
         map_name,
         top_level_key,
         second_level_key
       ]) do
    map_name = find_in_map_convert(map_name)
    top_level_key = find_in_map_convert(top_level_key)
    second_level_key = find_in_map_convert(second_level_key)

    find_in_map_return_value(map_name, top_level_key, second_level_key)
  end

  defp aws_fct_manager([{:name, _line, 'find_in_map'}], args),
    do: wrong_argument("find_in_map", 3, args)

  defp aws_fct_manager([{:name, line, 'map'} | data], []) do
    [{:name, _, mapping_name}, {:name, _, key_root}, {:name, _, key_name}] = data

    aws_fct_manager([{:name, line, 'find_in_map'}], [
      {:atom, List.to_atom(mapping_name)},
      {:atom, List.to_atom(key_root)},
      {:atom, List.to_atom(key_name)}
    ])
  end

  defp find_in_map_convert(item) do
    case item do
      {:atom, data} -> convert_atom_to_csl_string(data)
      {:string, data} -> {:string, data}
      {:module_fct, fct_name, args} -> {:module_fct, fct_name, args}
      _ -> {:error}
    end
  end

  defp find_in_map_return_value({:error}, _top_level_key, _second_level_key),
    do: {:error, "The argument n°0 waiting ':atom' or ':string' or 'function call'."}

  defp find_in_map_return_value(_map_name, {:error}, _second_level_key),
    do: {:error, "The argument n°1 waiting ':atom' or ':string' or 'function call'."}

  defp find_in_map_return_value(_map_name, _top_level_key, {:error}),
    do: {:error, "The argument n°2 waiting ':atom' or ':string' or 'function call'."}

  defp find_in_map_return_value(map_name, top_level_key, second_level_key),
    do:
      {:module_fct, "find_in_map",
       {:array,
        [
          map_name,
          top_level_key,
          second_level_key
        ]}}

  #################################### Error ##################################
  defp wrong_argument(fct_name, nb_args, args),
    do: {:error, "Wrong arguments for '#{fct_name}'. Waiting #{nb_args}, given #{length(args)}"}

  defp base_argument(fct_name, index, type_waiting, type_gived),
    do:
      {:error,
       "Bad type argument for '#{fct_name}'. The argument n°#{index} waiting #{type_waiting} and given '#{
         type_gived
       }'"}

  #################################### Util ##################################
  defp convert_list_to_name(n) do
    n
    |> List.to_string()
    |> Macro.camelize()
  end

  defp convert_atom_to_name(n) do
    n
    |> Atom.to_string()
    |> Macro.camelize()
  end

  defp convert_atom_to_csl_string(n), do: {:string, convert_atom_to_name(n)}
end
