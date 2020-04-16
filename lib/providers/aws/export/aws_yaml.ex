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
  alias CloudStackLang.Core.Util
  alias CloudStackLang.Providers.AWS.DependencyManager

  def gen(modules) do
    yaml_aws_resources =
      modules
      |> filter_by_type("Resource")
      |> generate_aws_resources_map

    # TODO check dependencies if found in map

    #    AWS :: Stack
    yaml_aws_global =
      modules
      |> filter_by_type("Stack")
      |> generate_aws_global_map

    data =
      yaml_aws_global
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

  # Generate all resource for AWS.
  # Input type is array.
  defp generate_aws_resources_map(aws_resources),
    do:
      aws_resources
      |> Enum.map(&generate_one_aws_resources/1)
      |> Map.new()

  # In AWS CloudFormation file, some data are not attached to a resource.
  defp generate_aws_global_map(aws_resources),
    do:
      aws_resources
      |> Enum.map(fn {_resource_name, _namespace, {:map, resource_properties}} ->
        resource_properties
      end)
      |> Util.merge_list_of_map()

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

  ##################################### Ref ###################################
  defp generate({:atom, data}, _indent) do
    ref =
      data
      |> Atom.to_string()
      |> Macro.camelize()

    "!Ref #{ref}"
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
