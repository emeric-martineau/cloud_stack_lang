defmodule CloudStackLang.CloudStackLang.Providers.AWS.Yaml do
  @moduledoc ~S"""
  This module generate YAML stream.

  ## Examples
    iex> module = %{"AvailabilityZone" => {:string, "eu-west-1a"}, "ImageId" => {:string, "ami-0713f98de93617bb4"}, "InstanceType" => {:string, "t2.micro"}}
    ...> CloudStackLang.CloudStackLang.Providers.AWS.Yaml.gen([{"YouKnowMyName", ["AWS", "Resource", "TheType"], {:map, module}}])
    "Resources:\n  YouKnowMyName:\n    Properties:\n      AvailabilityZone: eu-west-1a\n      ImageId: ami-0713f98de93617bb4\n      InstanceType: t2.micro\n    Type: AWS::TheType"

    iex> module = %{"a" => {:string, "SSH and HTTP"}, "b" => {:array, [map: %{"c" => {:string, "0.0.0.0/0"}, "d" => {:int, 22}, "e" => {:string, "tcp"}, "f" => {:int, 22}}, map: %{"g" => {:string, "0.0.0.0/0"}, "h" => {:int, 80}, "i" => {:string, "tcp"}, "j" => {:int, 80}}]}}
    ...> CloudStackLang.CloudStackLang.Providers.AWS.Yaml.gen([{"YouKnowMyName", ["AWS", "Resource", "TheType"], {:map, module}}])
    "Resources:\n  YouKnowMyName:\n    Properties:\n      a: SSH and HTTP\n      b:\n        - \n          c: 0.0.0.0/0\n          d: 22\n          e: tcp\n          f: 22\n        - \n          g: 0.0.0.0/0\n          h: 80\n          i: tcp\n          j: 80\n    Type: AWS::TheType"

    iex> module = %{"a" => {:map, %{"a" => {:int, 1}, "b" => {:int, 2}, "c" => {:array, [{:int, 0}, {:int, 1}]}}}, "b" => {:string, "hello"}}
    ...> CloudStackLang.CloudStackLang.Providers.AWS.Yaml.gen([{"YouKnowMyName", ["AWS", "Resource", "TheType"], {:map, module}}])
    "Resources:\n  YouKnowMyName:\n    Properties:\n      a:\n        a: 1\n        b: 2\n        c:\n          - 0\n          - 1\n      b: hello\n    Type: AWS::TheType"

    iex> module = %{"a" => {:map, %{"a" => {:int, 1}, "b" => {:int, 2}, "c" => {:array, [{:int, 0}, {:int, 1}]}}}, "b" => {:atom, :hello}}
    ...> CloudStackLang.CloudStackLang.Providers.AWS.Yaml.gen([{"YouKnowMyName", ["AWS", "Resource", "TheType"], {:map, module}}])
    "Resources:\n  YouKnowMyName:\n    Properties:\n      a:\n        a: 1\n        b: 2\n        c:\n          - 0\n          - 1\n      b: !Ref Hello\n    Type: AWS::TheType"

    iex> module = %{"a" => {:string, ":Thing"}}
    ...> CloudStackLang.CloudStackLang.Providers.AWS.Yaml.gen([{"YouKnowMyName", ["AWS", "Resource", "TheType"], {:map, module}}])
    "Resources:\n  YouKnowMyName:\n    Properties:\n      a: \":Thing\"\n    Type: AWS::TheType"

    iex> module = %{"a" => {:string, " Thing"}}
    ...> CloudStackLang.CloudStackLang.Providers.AWS.Yaml.gen([{"YouKnowMyName", ["AWS", "Resource", "TheType"], {:map, module}}])
    "Resources:\n  YouKnowMyName:\n    Properties:\n      a: \" Thing\"\n    Type: AWS::TheType"

    iex> module = %{"a" => {:string, "Thing\t"}}
    ...> CloudStackLang.CloudStackLang.Providers.AWS.Yaml.gen([{"YouKnowMyName", ["AWS", "Resource", "TheType"], {:map, module}}])
    "Resources:\n  YouKnowMyName:\n    Properties:\n      a: \"Thing\t\"\n    Type: AWS::TheType"

  """
  use CloudStackLang.Export.Yaml
  alias CloudStackLang.Core.Util

  def gen(modules) do
    yaml_aws_resources =
      modules
      |> filter_by_type("Resource")
      |> generate_aws_resources_map

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

  defp filter_by_type(aws_module, type),
    do:
      aws_module
      |> Enum.filter(fn {_module_name, namespace, _module_properties} ->
        [_prefixe_ns, domain | _tail] = namespace
        domain == type
      end)

  defp generate_aws_resources_map(aws_resources),
    do:
      aws_resources
      |> Enum.map(fn {resource_name, namespace, resource_properties} ->
        [prefixe_ns, _domain | tail] = namespace

        # Remove "Resource" and generate type
        resource_type =
          [prefixe_ns | tail]
          |> Enum.join("::")

        {
          resource_name,
          {:map,
           %{
             "Type" => {:string, resource_type},
             "Properties" => resource_properties
           }}
        }
      end)
      |> Map.new()

  defp generate_aws_global_map(aws_resources),
    do:
      aws_resources
      |> Enum.map(fn {_resource_name, _namespace, {:map, resource_properties}} ->
        resource_properties
      end)
      |> Util.merge_list_of_map()

  defp generate({:atom, data}, _indent) do
    ref =
      data
      |> Atom.to_string()
      |> Macro.camelize()

    "!Ref #{ref}"
  end

  # TODO add AWS function support
  # TODO add other thing
end
