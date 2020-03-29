defmodule CloudStackLang.Export.Yaml do
  @moduledoc ~S"""
  This module generate YAML stream.
  """
  defmacro __using__(_opts) do
    quote do
      def gen(data) do
        generate({:map, data}, "")
      end

      defp generate({:map, data}, indent) do
        next_indent = "#{indent}  "

        map =
          data
          |> Enum.map(fn {key, value} ->
            first_part =
              case value do
                {:map, _} -> "#{indent}#{key}:\n"
                {:array, _} -> "#{indent}#{key}:\n"
                _ -> "#{indent}#{key}: "
              end

            second_part = generate(value, next_indent)

            "#{first_part}#{second_part}"
          end)
          |> Enum.join("\n")
      end

      defp generate({:array, data}, indent) do
        first_indent = "#{indent}- "
        next_indent = "#{indent}  "

        data
        |> Enum.map(fn value ->
          first_part =
            case value do
              {:map, _} -> "#{first_indent}\n"
              {:array, _} -> "#{first_indent}\n"
              _ -> "#{first_indent}"
            end

          second_part = generate(value, next_indent)

          "#{first_part}#{second_part}"
        end)
        |> Enum.join("\n")
      end

      defp generate({:string, data}, indent) do
        # Todo escape if :, {, }, [, ], ,, &, *, #, ?, |, -, <, >, =, !, %, @, \
        # or end with space
        data
      end

      defp generate({:int, data}, indent) do
        Integer.to_string(data)
      end

      defp generate({:float, data}, indent) do
        Float.to_string(data)
      end
    end
  end
end
