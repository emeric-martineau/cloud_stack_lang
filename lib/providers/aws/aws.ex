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
      # TODO
      :find_in_map => {:manager, &aws_fct_manager/2},
      # TODO
      :get_att => {:manager, &aws_fct_manager/2},
      :get_azs => {:manager, &aws_fct_manager/2},
      # TODO
      :import_value => {:manager, &aws_fct_manager/2},
      # TODO
      :join => {:manager, &aws_fct_manager/2},
      # TODO
      :select => {:manager, &aws_fct_manager/2},
      # TODO
      :split => {:manager, &aws_fct_manager/2},
      # TODO
      :sub => {:manager, &aws_fct_manager/2},
      # TODO
      :transform => {:manager, &aws_fct_manager/2}
    }

  defp aws_fct_manager([{:name, _line, 'ref'}], [{:string, item}]),
    do: {:atom, String.to_atom(item)}

  defp aws_fct_manager([{:name, _line, 'ref'}], [{:atom, item}]), do: {:atom, item}

  ####################################### Ref #################################
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
    {:module_fct, "cidr", [{:string, ip_block}, {:int, count}, {:int, cidr_bits}]}
  end

  defp aws_fct_manager([{:name, _line, 'cidr'}], [
         {:module_fct, fct, data},
         {:int, count},
         {:int, cidr_bits}
       ]) do
    {:module_fct, "cidr", [{:module_fct, fct, data}, {:int, count}, {:int, cidr_bits}]}
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

  #################################### Error ##################################
  defp wrong_argument(fct_name, nb_args, args),
    do: {:error, "Wrong arguments for '#{fct_name}'. Waiting #{nb_args}, given #{length(args)}"}

  defp base_argument(fct_name, index, type_waiting, type_gived),
    do:
      {:error,
       "Bad type argument for '#{fct_name}'. The argument n°#{index} waiting #{type_waiting} and given '#{
         type_gived
       }'"}
end
