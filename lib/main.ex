defmodule CloudStackLang.Main do
  def main(args) do
    filename = Enum.fetch!(args, 0)

    IO.puts "Parsing #{filename}"
    text = File.read!(filename)

    CloudStackLang.Parser.parse_and_eval(text, true, %{}, CloudStackLang.Functions.Base.get_map())
  end
end
