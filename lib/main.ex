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
defmodule CloudStackLang.Main do
  @version Mix.Project.config()[:version]

  alias CloudStackLang.Main.Parse
  alias CloudStackLang.Main.Help

  def main(args) do
    options = [
      strict: [
        debug: :boolean,
        version: :boolean,
        help: :boolean,
        output: :string
      ],
      aliases: [
        d: :debug,
        v: :version,
        h: :help,
        o: :output
      ]
    ]

    # TODO add output formal yaml or json
    OptionParser.parse(args, options)
    |> check_unknow_options(options)
    |> case do
      true -> System.halt(0)
      _ -> System.halt(1)
    end
  end

  defp check_unknow_options({opts, files, []}, options) do
    debug = Keyword.get(opts, :debug, false)
    app_version = Keyword.get(opts, :version)
    app_help = Keyword.get(opts, :help, false)
    output_format = Keyword.get(opts, :output, "%dirname/%filename.%format")

    cond do
      app_version == true ->
        version()

      app_help == true ->
        Help.display(options)

      true ->
        Parse.parse_files(debug, files, output_format)
    end
  end

  defp check_unknow_options({_opts, _files, unknow_options}, _options) do
    opts =
      unknow_options
      |> Enum.map(fn {switch, _value} -> switch end)
      |> Enum.join(" ")

    IO.puts(:stderr, "unknown option: #{opts}")

    false
  end

  defp version() do
    IO.puts("Cloud Stack Lang version #{@version}")
    IO.puts("Copyright 2020 - Emeric MARTINEAU")

    true
  end
end
