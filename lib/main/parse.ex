defmodule CloudStackLang.Main.Parse do
  @moduledoc ~S"""
    This module contain some functions for write file when it's parser.
  """
  alias CloudStackLang.Providers

  def parse_files(_debug, [], _output) do
    IO.puts(:stderr, "Error! You must provide a filename.")
    IO.puts(:stderr, "Please run 'csl --help' for more information.")

    false
  end

  def parse_files(debug, files, output_format) do
    files
    |> Enum.filter(fn f -> not File.exists?(f) end)
    |> case do
      [] ->
        run_all_files(true, files, debug, output_format)

      missing_files ->
        Enum.each(missing_files, fn f -> IO.puts(:stderr, "File #{f} not found!") end)

        false
    end
  end

  defp run_all_files(true, [current_file | tail], debug, output_format) do
    continue_run =
      run(debug, output_format, current_file, CloudStackLang.Functions.Base.get_map(), %{})

    run_all_files(continue_run, tail, debug, output_format)
  end

  # All files are parsed with success
  defp run_all_files(true, [], _debug, _output_format), do: true

  defp run_all_files(false, _files, _debug, _output_format), do: false

  defp run(debug, output_format, filename, fct, modules_fct) do
    IO.puts("Parsing file #{filename}")

    File.read!(filename)
    |> CloudStackLang.Parser.parse_and_eval(debug, %{}, fct, modules_fct)
    |> manage_parse_and_eval_return(filename, output_format)
  end

  defp manage_parse_and_eval_return({:error, line, msg}, filename, _output_format) do
    IO.puts(:stderr, "Error in script '#{filename}' at line #{line}: #{msg}")

    false
  end

  defp manage_parse_and_eval_return(
         {line, :cloud_stack_lang_parser, msg},
         filename,
         _output_format
       ) do
    # TODO write better message
    # actually for this {28, :cloud_stack_lang_parser, ['syntax error before: ', 'close_parenthesis']}
    # we wrire "Error in script 'xxx.csl' at line 28: syntax error before: close_parenthesis"
    IO.puts(:stderr, "Error in script '#{filename}' at line #{line}: #{msg}")

    false
  end

  # TODO extension come from provider
  # TODO support output_format '-' for stdin
  # TODO support directory file and recursive mode -> generate only one file in this case
  defp manage_parse_and_eval_return(map, filename, output_format),
    do:
      Providers.get_list()
      |> generate_file(map[:modules], filename, output_format)

  defp generate_file([current_provider | next_providers], modules, filename, output_format) do
    current_provider.prefix()
    |> filter_provider(modules)
    |> case do
      [] ->
        generate_file(next_providers, modules, filename, output_format)

      mods ->
        # TODO if multi provider in file, generate multi file ?
        current_provider.export_to(mods, "yaml")
        |> write_result(filename, output_format, "yaml", current_provider.name())
    end
  end

  defp generate_file([], _modules, filename, _output_format) do
    IO.puts(:stderr, "No provider found to manage module in file '#{filename}'!")
    false
  end

  defp filter_provider(prefix, modules),
    do:
      modules
      |> Enum.filter(fn {_module_name, namespace, _module_properties} ->
        [prefixe_ns | _tail] = namespace
        prefixe_ns == prefix
      end)

  defp write_result(content, filename, output_format, extension, provider) do
    new_filename = generate_new_filename(filename, output_format, extension, provider)

    new_filename
    |> File.write(content)
    |> manage_write_file_error(new_filename, filename)
  end

  defp manage_write_file_error({:error, msg}, new_filename, filename) do
    err_msg = build_error_message({:error, msg}, new_filename, filename)
    IO.puts(:stderr, err_msg)

    false
  end

  defp manage_write_file_error(_, new_filename, _filename) do
    IO.puts("Writting file '#{new_filename}' done.")

    true
  end

  defp build_error_message({:error, :enoent}, new_filename, filename),
    do: build_error_message(new_filename, filename, "file does not exist")

  defp build_error_message({:error, :enotdir}, new_filename, filename),
    do: build_error_message(new_filename, filename, "not a directory")

  defp build_error_message({:error, :enospc}, new_filename, filename),
    do: build_error_message(new_filename, filename, "no space left on the device")

  defp build_error_message({:error, :eacces}, new_filename, filename),
    do: build_error_message(new_filename, filename, "missing permission for writing")

  defp build_error_message({:error, :eisdir}, new_filename, filename),
    do: build_error_message(new_filename, filename, "file is a directory")

  defp build_error_message(error, new_filename, filename),
    do: "Error when write file '#{new_filename}' (for '#{filename}'): #{error}"

  defp generate_new_filename(filename, output_format, format, provider) do
    dirname = Path.dirname(filename)
    basename = Path.basename(filename)
    extname = Path.extname(filename)

    output_format
    |> String.replace("%dirname", dirname)
    |> String.replace("%filename", basename)
    |> String.replace("%extension", extname)
    |> String.replace("%format", format)
    |> String.replace("%provider", provider)
  end
end
