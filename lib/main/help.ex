defmodule CloudStackLang.Main.Help do
  @moduledoc ~S"""
    This module contain some functions for display help.
  """
  def display(options) do
    switches =
      Keyword.get(options, :strict, [])
      |> Enum.map(fn {key, _type} -> convert_atom_to_string(key) end)

    aliases =
      Keyword.get(options, :aliases, [])
      |> Enum.map(fn {key, value} ->
        {convert_atom_to_string(value), convert_atom_to_string(key)}
      end)
      |> Enum.into(%{})

    opts =
      switches
      |> Enum.sort()
      |> Enum.map(fn key -> convert_to_switch(key, aliases[key]) end)
      |> Enum.join(" ")

    IO.puts("""
    Cloud Stack Lang is a new way to use native cloud IaaC like CloudFormation for AWS.

    Usage: csl #{opts} file(s)

    Examples:

    csl FILE       - Read FILE and output in file in same directory with default extention
    csl -d FILE    - Read FILE and output in file in same directory with default extention
                     with debug information
    csl -f '%dirname/%filename.%extension.%format' FILE
                   - Read FILE and output in file in same directory with specified name

    The --help and --version options can be given instead of a task for usage and versioning information.
    """)

    0
  end

  defp convert_to_switch(long, short), do: "[--#{long}|-#{short}]"

  defp convert_atom_to_string(atom),
    do:
      Atom.to_string(atom)
      |> String.replace_prefix(":", "")
end
