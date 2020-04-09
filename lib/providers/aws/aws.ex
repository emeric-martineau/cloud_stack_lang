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
      :get_att => {:manager, &aws_fct_manager/2},
      :get_azs => {:manager, &aws_fct_manager/2},
      :import_value => {:manager, &aws_fct_manager/2},
      :join => {:manager, &aws_fct_manager/2},
      :split => {:manager, &aws_fct_manager/2},
      :sub => {:manager, &aws_fct_manager/2},
      :transform => {:manager, &aws_fct_manager/2}
    }

  defp aws_fct_manager([{:name, _line, 'ref'}], [{:string, item}]) do
    {:atom, String.to_atom(item)}
  end

  defp aws_fct_manager([{:name, _line, 'ref'}], [{:atom, item}]) do
    {:atom, item}
  end

  defp aws_fct_manager([{:name, _line, 'ref'}], [{type, _item}]),
    do: base_argument("ref", 0, "':atom' or ':string'", type)

  defp aws_fct_manager([{:name, _line, 'ref'}], args),
    do: wrong_argument("ref", args)

  defp aws_fct_manager([{:name, _line, 'base64'}], [{:string, item}]) do
    {:module_fct, "base64", {:string, item}}
  end

  defp aws_fct_manager([{:name, _line, 'base64'}], [{:module_fct, fct, data}]) do
    {:module_fct, "base64", {:module_fct, fct, data}}
  end

  defp aws_fct_manager([{:name, _line, 'base64'}], [{type, _item}]),
       do: base_argument("base64", 0, "':string' or another function", type)

  defp aws_fct_manager([{:name, _line, 'base64'}], args),
       do: wrong_argument("base64", args)

  defp aws_fct_manager(namespace, args) do
    IO.inspect(namespace)
    IO.inspect(args)
    {:string, "aws_fct_manager is calling !"}
  end

  defp wrong_argument(fct_name, args), do: {:error, "Wrong arguments for '#{fct_name}'. Waiting 1, given #{length(args)}"}

  defp base_argument(fct_name, index, type_waiting, type_gived),
       do:
         {:error,
         "Bad type argument for '#{fct_name}'. The argument n°#{index} waiting #{type_waiting} and given '#{
           type_gived
         }'"}
end
