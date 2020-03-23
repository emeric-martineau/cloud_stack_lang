defmodule CloudStackLang.Main do
  @version Mix.Project.config[:version]

  def main(args) do
    options = [
      switches: [
        file: :string,
        debug: :boolean,
        version: :boolean,
        help: :boolean
      ],
      aliases: [
        f: :file,
        d: :debug,
        v: :version,
        h: :help
      ]
    ]

    {opts, _, _}= OptionParser.parse(args, options)

    debug = Keyword.get(opts, :debug, false)
    filename = Keyword.get(opts, :file)
    app_version = Keyword.get(opts, :version)
    app_help = Keyword.get(opts, :help)

    cond do
      app_version == true -> version()
      app_help == true -> help()
      true -> run(debug, filename, CloudStackLang.Functions.Base.get_map())
    end
  end

  defp run(_debug, nil, _fct) do
    IO.puts(:stderr, "Error! You must provide a filename.")
    IO.puts(:stderr, "Please run 'csl --help' for more information.")

    System.halt(1)
  end

  defp run(debug, filename, fct) do
    IO.puts "Parsing file #{filename}"

    text = File.read!(filename)

    ret = CloudStackLang.Parser.parse_and_eval(text, debug, %{}, fct)

    case ret do
      {:error, line, msg} ->
        IO.puts(:stderr, "Error in script '#{filename}' at line #{line}: #{msg}")
        System.halt(1)
      _ -> System.halt(0)
    end
  end

  defp version() do
     IO.puts("Cloud Stack Lang version #{@version}")
     IO.puts("Copyright 2020 - Emeric MARTINEAU")
  end

  defp help() do
    IO.puts(
    """
    Cloud Stack Lang is a new way to use native cloud IaaC like CloudFormation for AWS.

    Usage: csl

    Examples:

    csl             - Invokes the default task (mix run) in a project
    csl -f FILE     - Read FILE and output in console the result

    The --help and --version options can be given instead of a task for usage and versioning information.
    """
    )
  end
end
