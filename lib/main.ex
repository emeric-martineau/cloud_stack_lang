defmodule CloudStackLang.Main do
  @version Mix.Project.config()[:version]

  alias CloudStackLang.File.Parse

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

    cond do
      app_version == true ->
        version()

      app_help == true ->
        help(options)

      true ->
        case Parse.parse_files(debug, files, output_format) do
          true -> System.halt(0)
          _ -> System.halt(1)
        end
    end
  end

  defp version() do
    IO.puts("Cloud Stack Lang version #{@version}")
    IO.puts("Copyright 2020 - Emeric MARTINEAU")
  end

  defp help(options) do
    # TODO display list of option

    IO.puts("""
    Cloud Stack Lang is a new way to use native cloud IaaC like CloudFormation for AWS.

    Usage: csl <TODO> file(s)

    Examples:

    csl FILE       - Read FILE and output in file in same directory with default extention
    csl -d FILE    - Read FILE and output in file in same directory with default extention
                     with debug information
    csl -f '%dirname/%filename.%extension.%format' FILE
                   - Read FILE and output in file in same directory with specified name

    The --help and --version options can be given instead of a task for usage and versioning information.
    """)
  end
end
