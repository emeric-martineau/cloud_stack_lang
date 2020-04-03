defmodule CloudStackLang.Main do
  @version Mix.Project.config()[:version]

  alias CloudStackLang.Main.Parse
  alias CloudStackLang.Main.Help

  def main(args) do
    options = [
      switches: [
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

    {opts, files, _} = OptionParser.parse(args, options)

    # TODO fail if unknow options

    debug = Keyword.get(opts, :debug, false)
    app_version = Keyword.get(opts, :version)
    app_help = Keyword.get(opts, :help, false)
    output_format = Keyword.get(opts, :output, "%dirname/%filename.%format")

    ret =
      cond do
        app_version == true ->
          version()

        app_help == true ->
          Help.display(options)

        true ->
          Parse.parse_files(debug, files, output_format)
      end

    case ret do
      true -> System.halt(0)
      _ -> System.halt(1)
    end
  end

  defp version() do
    IO.puts("Cloud Stack Lang version #{@version}")
    IO.puts("Copyright 2020 - Emeric MARTINEAU")

    0
  end
end
