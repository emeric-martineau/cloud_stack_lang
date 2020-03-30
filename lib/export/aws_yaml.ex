defmodule CloudStackLang.Export.AwsYaml do
  @moduledoc ~S"""
  This module generate YAML stream.

  ## Examples
    iex> module = %{"AvailabilityZone" => {:string, "eu-west-1a"}, "ImageId" => {:string, "ami-0713f98de93617bb4"}, "InstanceType" => {:string, "t2.micro"}}
    ...> CloudStackLang.Export.AwsYaml.gen([{"YouKnowMyName", "TheType", module}])
    ["YouKnowMyName:\n  Properties:\n    AvailabilityZone: eu-west-1a\n    ImageId: ami-0713f98de93617bb4\n    InstanceType: t2.micro\n  Type: TheType"]

    iex> module = %{"a" => {:string, "SSH and HTTP"}, "b" => {:array, [map: %{"c" => {:string, "0.0.0.0/0"}, "d" => {:int, 22}, "e" => {:string, "tcp"}, "f" => {:int, 22}}, map: %{"g" => {:string, "0.0.0.0/0"}, "h" => {:int, 80}, "i" => {:string, "tcp"}, "j" => {:int, 80}}]}}
    ...> CloudStackLang.Export.AwsYaml.gen([{"YouKnowMyName", "TheType", module}])
    ["YouKnowMyName:\n  Properties:\n    a: SSH and HTTP\n    b:\n      - \n        c: 0.0.0.0/0\n        d: 22\n        e: tcp\n        f: 22\n      - \n        g: 0.0.0.0/0\n        h: 80\n        i: tcp\n        j: 80\n  Type: TheType"]

    iex> module = %{"a" => {:map, %{"a" => {:int, 1}, "b" => {:int, 2}, "c" => {:array, [{:int, 0}, {:int, 1}]}}}, "b" => {:string, "hello"}}
    ...> CloudStackLang.Export.AwsYaml.gen([{"YouKnowMyName", "TheType", module}])
    ["YouKnowMyName:\n  Properties:\n    a:\n      a: 1\n      b: 2\n      c:\n        - 0\n        - 1\n    b: hello\n  Type: TheType"]

    iex> module = %{"a" => {:map, %{"a" => {:int, 1}, "b" => {:int, 2}, "c" => {:array, [{:int, 0}, {:int, 1}]}}}, "b" => {:atom, :hello}}
    ...> CloudStackLang.Export.AwsYaml.gen([{"YouKnowMyName", "TheType", module}])
    ["YouKnowMyName:\n  Properties:\n    a:\n      a: 1\n      b: 2\n      c:\n        - 0\n        - 1\n    b: !Ref Hello\n  Type: TheType"]

  """
  use CloudStackLang.Export.Yaml

  def gen(modules) do
    modules
    |> Enum.map(fn {module_name, module_type, module_properties} ->
      data = %{
        module_name =>
          {:map,
          %{
            "Type" => {:string, module_type},
            "Properties" => {:map, module_properties}
          }}
      }

      generate({:map, data}, "")
    end)
    |> Enum.join("\n")
  end

  defp generate({:atom, data}, _indent) do
    ref =
      data
      |> Atom.to_string()
      |> Macro.camelize()

    "!Ref #{ref}"
  end
end
