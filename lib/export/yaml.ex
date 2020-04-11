defmodule CloudStackLang.Export.Yaml do
  @moduledoc ~S"""
  This module generate YAML stream.
  """
  defmacro __using__(_opts) do
    quote do
      defp generate({:map, data}, indent) do
        next_indent = "#{indent}  "

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
        # Escape if :, {, }, [, ], ,, &, *, #, ?, |, -, <, >, =, !, %, @, \
        # or end with space
        special_char = String.match?(data, ~r/(^[:{}[\],&*#?|\-<>=!%@\s])|(\s$)/)
        new_line = String.match?(data, ~r/\n|\r/)

        case special_char || new_line do
          true ->
            data =
              data
              |> String.replace("\\", "\\\\")
              |> String.replace("\"", "\\\"")
              |> String.replace("\r", "\\r")
              |> String.replace("\n", "\\n")

            "\"#{data}\""

          false ->
            data
        end
      end

      defp generate({:int, data}, indent), do: Integer.to_string(data)

      defp generate({:float, data}, indent), do: Float.to_string(data)

      defp generate({:bool, true}, indent), do: "true"

      defp generate({:bool, false}, indent), do: "false"
    end
  end
end
