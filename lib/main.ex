defmodule CloudStackLang.Main do
  @version Mix.Project.config()[:version]

  alias CloudStackLang.Export.AwsYaml

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
      app_version == true -> version()
      app_help == true -> help(options)
      true -> parse_files(debug, files, output_format)
    end
  end

  defp parse_files(_debug, [], _output) do
    IO.puts(:stderr, "Error! You must provide a filename.")
    IO.puts(:stderr, "Please run 'csl --help' for more information.")

    System.halt(1)
  end

  defp parse_files(debug, files, output_format) do
    not_found_files =
      files
      |> Enum.filter(fn f -> not File.exists?(f) end)

    case not_found_files do
      [] ->
        Enum.each(files, fn f ->
          run(debug, output_format, f, CloudStackLang.Functions.Base.get_map(), %{})
        end)

        System.halt(0)

      missing_files ->
        Enum.each(missing_files, fn f -> IO.puts(:stderr, "File #{f} not found!") end)
        System.halt(1)
    end
  end

  defp run(debug, output_format, filename, fct, modules_fct) do
    IO.puts("Parsing file #{filename}")

    text = File.read!(filename)

    ret = CloudStackLang.Parser.parse_and_eval(text, debug, %{}, fct, modules_fct)

    case ret do
      {:error, line, msg} ->
        IO.puts(:stderr, "Error in script '#{filename}' at line #{line}: #{msg}")
        System.halt(1)

      map ->
        content = AwsYaml.gen(map[:modules])
        # TODO extension come from AwsYaml
        new_filename = generate_new_filename(filename, output_format, "yaml")

        # TODO support output_format '-' for stdin
        # TODO support directory file and recursive mode

        case File.write(new_filename, content) do
          {:error, msg} ->
            IO.puts(
              :stderr,
              "Error when write file '#{new_filename}' (for '#{filename}'): #{
                get_write_error(msg)
              }"
            )

            System.halt(1)

          _ ->
            IO.puts("Writting file '#{new_filename}' done.")
        end
    end
  end

  defp get_write_error(msg) do
    case msg do
      :enoent -> "file does not exist"
      :enotdir -> "not a directory"
      :enospc -> "no space left on the device"
      :eacces -> "missing permission for writing"
      :eisdir -> "file is a directory"
    end
  end

  defp generate_new_filename(filename, output_format, format) do
    dirname = Path.dirname(filename)
    basename = Path.basename(filename)
    extname = Path.extname(filename)

    output_format
    |> String.replace("%dirname", dirname)
    |> String.replace("%filename", basename)
    |> String.replace("%extension", extname)
    |> String.replace("%format", format)
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
