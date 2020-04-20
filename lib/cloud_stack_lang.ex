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
defmodule CloudStackLang.Parser do
  @moduledoc ~S"""
  This module parse and run code.

  ## Examples

    iex> CloudStackLang.Parser.parse_and_eval("a = 1", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:int, 1}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1_000_000", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:int, 1000000}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1 + 1", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:int, 2}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1 - 1", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:int, 0}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 4 / 2", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:int, 2}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 7\nb = 4\nresult = a + b * 10 / 2", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:int, 7}, b: {:int, 4}, result: {:int, 27}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = :toto", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:atom, :toto}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("// This is single line comment\na = :toto", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:atom, :toto}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1\nb='no interpolate ${a} \\' with single quote'", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:int, 1}, b: {:string, "no interpolate ${a} ' with single quote"}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1\nb=\"interpolate ${a} \\\" with double quote\"", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:int, 1}, b: {:string, "interpolate 1 \" with double quote"}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1.3", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:float, 1.3}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1.2_3_4", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:float, 1.234}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1.2_3_4e2_3", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:float, 1.234e23}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 1.3e2", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:float, 1.3e2}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = -1.3e2", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:float, -1.3e2}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = -1", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:int, -1}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = {}", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:map, %{}}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = { :a = 2 }", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:map, %{:a => {:int, 2}}}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = { :a = 2 'b' = 3}", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:map, %{:a => {:int, 2}, "b" => {:int, 3}}}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = []", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:array, []}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = [ 2 ]", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:array, [ {:int, 2} ]}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = [ 2 3 ]", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:array, [ {:int, 2}, {:int, 3} ]}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 0xfa", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:int, 250}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 0xFA", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:int, 250}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = 0o531", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:int, 345}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = (1 * (3 + 5))", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:int, 8}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = { :a = 1}\nb = a[:a]", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a: {:map, %{ :a => {:int, 1}}}, b: {:int, 1}}, modules: [], modules_fct: %{}}

    iex> CloudStackLang.Parser.parse_and_eval("a = { :a = { :b = 2 } }\nb = a[:a][:b]", false, %{}, %{}, %{})
    %{fct: %{}, vars: %{a:
      {:map, %{
        :a => {:map, %{
          :b => {:int, 2}
        }}
      }},
    b: {:int, 2}}, modules: [], modules_fct: %{} }
  """
  alias CloudStackLang.Core.Util
  alias CloudStackLang.Core.Reduce
  alias CloudStackLang.Core.Module

  #
  # Save the module in state of parser.
  #
  # Examples:
  #
  #    iex> namespace = [{:name, 1, 'AWS'}, {:name, 1, 'Resource', {:name, 1, 'Type'}}]
  #    ...> name = {:atom, :my_module}
  #    ...> properties = %{ "availability_zone" => {:string, "eu-west-1a"}
  #    ...> save_module_in_state(namespace, name, properties, %{}, [])
  #
  defp save_module_in_state(namespace, name, properties, state, next_running_code) do
    cloud_type = Module.convert_list_of_name_to_list_of_string(namespace)

    new_properties = Module.convert_all_map_key_to_camelcase({:map, properties})

    cloud_name =
      name
      |> Module.convert_module_name(fn x -> Reduce.to_value(x, %{}) end)

    cloud_module = {cloud_name, cloud_type, new_properties}

    new_state =
      state
      |> Map.update(:modules, [], fn v -> [cloud_module | v] end)
      |> Map.update(:in_module, false, fn _ -> false end)

    evaluate_tree(next_running_code, new_state)
  end

  #
  # Save the module in state of parser.
  #
  # Examples:
  #
  #    iex> namespace = [{:name, 1, 'AWS'}, {:name, 1, 'Resource', {:name, 1, 'Type'}}]
  #    ...> name = {:atom, :my_module}
  #    ...> args = {:map, %{ "availability_zone" => {:string, "eu-west-1a"}}
  #    ...> save_module_in_state(namespace, name, args, %{}, [])
  #
  defp save_module_without_properties_in_state(namespace, name, args, state, next_running_code) do
    cloud_type = Module.convert_list_of_name_to_list_of_string(namespace)

    cloud_name =
      name
      |> Module.convert_module_name(fn x -> Reduce.to_value(x, %{}) end)

    cloud_module = {cloud_name, cloud_type, args}

    new_state =
      state
      |> Map.update(:modules, [], fn v -> [cloud_module | v] end)
      |> Map.update(:in_module, false, fn _ -> false end)

    evaluate_tree(next_running_code, new_state)
  end

  #
  # Evaluate assignation `a = 1`.
  #
  # Examples:
  #
  #    iex> evaluate_tree([{:assign, {:name, 1, 'variable_name'}, {:float, 32, '1.3'}} | [], %{})
  #
  defp evaluate_tree([{:assign, {:name, line, variable_name}, variable_expr_value} | tail], state) do
    Reduce.to_value(variable_expr_value, state)
    |> case do
      {:error, line, msg} ->
        {:error, line, msg}

      {:void} ->
        {:error, line, "Error, a function return void value. Cannot be assigned to variable."}

      value ->
        key = List.to_atom(variable_name)

        new_state = Map.update(state, :vars, %{}, fn v -> Map.merge(v, %{key => value}) end)

        evaluate_tree(tail, new_state)
    end
  end

  #
  # Evaluate calling function.
  #
  # Examples:
  #
  #    iex> evaluate_tree([{:fct_call, [{:name, 1, 'base64_encode'}], [{:interpolate_string, 71, '"1"'}]} | [], %{})
  #
  defp evaluate_tree([{:fct_call, namespace, args} | tail], state) do
    Reduce.to_value({:fct_call, namespace, args}, state)
    |> case do
      {:error, line, msg} -> {:error, line, msg}
      _ -> evaluate_tree(tail, state)
    end
  end

  #
  # Evaluate module declaration.
  #
  # Examples:
  #
  #    iex> evaluate_tree(
  #    [
  #      {:module,
  #        [
  #          {:name, 1, 'AWS'},
  #          {:name, 1, 'Resource'},
  #          {:name, 1, 'EC2'},
  #          {:name, 1, 'Instance'}
  #        ], {:atom, 1, ':my_instance'},
  #        {:build_module_map, {:open_map, 1},
  #          [
  #            {:module_map_arg, {:name, 2, 'availability_zone'},
  #              {:interpolate_string, 2, '"eu-west-1a"'}},
  #            {:module_map_arg, {:name, 3, 'image_id'},
  #              {:interpolate_string, 3, '"ami-0713f98de93617bb4"'}},
  #            {:module_map_arg, {:name, 4, 'instance_type'},
  #              {:interpolate_string, 4, '"t2.micro"'}},
  #            {:module_map_arg, {:name, 5, 'security_groups'},
  #              {:fct_call, [{:name, 5, 'ref'}], []}}
  #          ]}}
  #      | []
  #    ], %{})
  #
  defp evaluate_tree(
         [{:module, namespace, name, {:build_module_map, _, properties}} | tail],
         state
       ) do
    # Create new state to authorize use name in key of map
    module_state =
      state
      |> Map.update(:in_module, true, fn _ -> true end)

    # Merge global function and module function only for properties
    module_properties_state =
      module_state
      |> Map.update(:fct, %{}, fn fct ->
        Map.merge(fct, Util.get_module_fct(module_state, namespace))
      end)

    new_props =
      properties
      |> Enum.map(fn {:module_map_arg, {:name, _line, prop_name}, value} ->
        name =
          prop_name
          |> List.to_string()

        {name, Reduce.to_value(value, module_properties_state)}
      end)
      |> Enum.into(%{})

    fct_reduce = fn {_prop_name, value} -> value end

    # Check if error in properties
    Util.call_if_no_error(new_props, fct_reduce, &save_module_in_state/5, [
      namespace,
      name,
      new_props,
      module_state,
      tail
    ])
  end

  #
  # Evaluate module declaration.
  #
  # Examples:
  #
  #    iex> evaluate_tree(
  #    [
  #      {:module,
  #        [
  #          {:name, 1, 'AWS'},
  #          {:name, 1, 'Resource'},
  #          {:name, 1, 'EC2'},
  #          {:name, 1, 'Instance'}
  #        ], {:atom, 1, ':my_instance'},
  #        {:build_map, {:open_map, 1},
  #          [
  #            {:module_map_arg, {:name, 2, 'availability_zone'},
  #              {:interpolate_string, 2, '"eu-west-1a"'}},
  #            {:module_map_arg, {:name, 3, 'image_id'},
  #              {:interpolate_string, 3, '"ami-0713f98de93617bb4"'}},
  #            {:module_map_arg, {:name, 4, 'instance_type'},
  #              {:interpolate_string, 4, '"t2.micro"'}},
  #            {:module_map_arg, {:name, 5, 'security_groups'},
  #              {:fct_call, [{:name, 5, 'ref'}], []}}
  #          ]}}
  #      | []
  #    ], %{})
  #
  defp evaluate_tree([{:module, namespace, name, {:build_map, line, properties}} | tail], state) do
    # Merge global function and module function only for properties
    module_state =
      state
      |> Map.update(:fct, %{}, fn fct ->
        Map.merge(fct, Util.get_module_fct(state, namespace))
      end)

    new_props = Reduce.to_value({:build_map, line, properties}, module_state)

    fct_reduce = fn {_prop_name, value} -> value end

    # Check if error in properties
    Util.call_if_no_error([new_props], fct_reduce, &save_module_without_properties_in_state/5, [
      namespace,
      name,
      new_props,
      module_state,
      tail
    ])
  end

  #
  # Evaluate module declaration.
  #
  # Examples:
  #
  #    iex> evaluate_tree(
  #    [
  #      {:module,
  #        [
  #          {:name, 1, 'AWS'},
  #          {:name, 1, 'Resource'},
  #          {:name, 1, 'EC2'},
  #          {:name, 1, 'Instance'}
  #        ], {:atom, 1, ':my_instance'},
  #        {:name, 3, 'data}}
  #      | []
  #    ], %{:vars => {:data => {:map, %{} }  } })
  #
  defp evaluate_tree([{:module, namespace, name, {:name, line, properties}} | tail], state) do
    # Merge global function and module function only for properties
    module_state =
      state
      |> Map.update(:fct, %{}, fn fct ->
        Map.merge(fct, Util.get_module_fct(state, namespace))
      end)

    new_props = Reduce.to_value({:name, line, properties}, module_state)

    fct_reduce = fn {_prop_name, value} -> value end

    # Check if map
    fct_no_error = fn namespace, name, new_props, module_state, tail ->
      case new_props do
        {:map, _data} ->
          save_module_without_properties_in_state(
            namespace,
            name,
            new_props,
            module_state,
            tail
          )

        {type, _data} ->
          {:error, line, "Module args can be only a map. Receive: #{type}."}
      end
    end

    # Check if error in properties
    Util.call_if_no_error([new_props], fct_reduce, fct_no_error, [
      namespace,
      name,
      new_props,
      module_state,
      tail
    ])
  end

  defp evaluate_tree([], state), do: state

  defp evaluate_tree(_, state), do: state

  defp process_tree({:error, err}, true, _state) do
    IO.puts("\nParse error")
    IO.inspect(err)

    err
  end

  defp process_tree({:error, err}, false, _state), do: err

  defp process_tree({:ok, tree}, true, state) do
    IO.puts("\nParse tree")
    IO.inspect(tree, pretty: true)

    result = evaluate_tree(tree, state)

    IO.puts("\nFinal state")
    IO.inspect(result, pretty: true)

    result
  end

  defp process_tree({:ok, tree}, false, state), do: evaluate_tree(tree, state)

  defp process_parse({:error, line, result}, _debug, _state), do: {:error, line, result}

  defp process_parse({:ok, tokens, _line}, debug, state),
    do:
      :cloud_stack_lang_parser.parse(tokens)
      |> process_tree(debug, state)

  def parse_and_eval(string, debug, state_vars, state_fct, state_modules_fct) do
    state = %{
      :vars => state_vars,
      :fct => state_fct,
      :modules_fct => state_modules_fct,
      :modules => []
    }

    :cloud_stack_lang_lexer.string(String.to_charlist(string))
    |> Util.debug_parse(debug, state)
    |> process_parse(debug, state)
  end
end
