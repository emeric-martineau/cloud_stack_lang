defmodule CloudStackLang.Providers.AWS do
  @moduledoc ~S"""
  This module contain the AWS provider.
  """
  alias CloudStackLang.CloudStackLang.Providers.AWS.Yaml

  def prefix(), do: "AWS"

  def name(), do: "aws"

  def export_to(modules, format) do
    case format do
      "yaml" -> Yaml.gen(modules)
      v -> {:error, "Unsupported format #{v}"}
    end
  end
end
