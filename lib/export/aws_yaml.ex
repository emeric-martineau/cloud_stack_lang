defmodule CloudStackLang.Export.AwsYaml do
  @moduledoc ~S"""
  This module generate YAML stream.

  ## Examples
    iex> CloudStackLang.Export.AwsYaml.gen(%{"AvailabilityZone" => {:string, "eu-west-1a"}, "ImageId" => {:string, "ami-0713f98de93617bb4"}, "InstanceType" => {:string, "t2.micro"}})
    "AvailabilityZone: eu-west-1a\nImageId: ami-0713f98de93617bb4\nInstanceType: t2.micro"

    iex> CloudStackLang.Export.AwsYaml.gen(%{"a" => {:string, "SSH and HTTP"}, "b" => {:array, [map: %{"c" => {:string, "0.0.0.0/0"}, "d" => {:int, 22}, "e" => {:string, "tcp"}, "f" => {:int, 22}}, map: %{"g" => {:string, "0.0.0.0/0"}, "h" => {:int, 80}, "i" => {:string, "tcp"}, "j" => {:int, 80}}]}})
    "a: SSH and HTTP\nb:\n  - \n    c: 0.0.0.0/0\n    d: 22\n    e: tcp\n    f: 22\n  - \n    g: 0.0.0.0/0\n    h: 80\n    i: tcp\n    j: 80"

    iex> CloudStackLang.Export.AwsYaml.gen(%{"a" => {:map, %{"a" => {:int, 1}, "b" => {:int, 2}, "c" => {:array, [{:int, 0}, {:int, 1}]}}}, "b" => {:string, "hello"}})
    "a:\n  a: 1\n  b: 2\n  c:\n    - 0\n    - 1\nb: hello"

    iex> CloudStackLang.Export.AwsYaml.gen(%{"a" => {:map, %{"a" => {:int, 1}, "b" => {:int, 2}, "c" => {:array, [{:int, 0}, {:int, 1}]}}}, "b" => {:atom, :hello}})
    "a:\n  a: 1\n  b: 2\n  c:\n    - 0\n    - 1\nb: !Ref Hello"

  """
  use CloudStackLang.Export.Yaml

  defp generate({:atom, data}, indent) do
    ref = data
    |> Atom.to_string
    |> Macro.camelize

    "!Ref #{ref}"
  end
end