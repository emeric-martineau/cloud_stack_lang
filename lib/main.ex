defmodule CloudStackLang.Main do
  def process_parse({:error, result}) do
    IO.puts "\nParse error"
    IO.inspect result
  end

  def process_parse({:ok, tree}) do
    IO.puts "\nParse tree"
    IO.inspect tree, pretty: true
    state = CloudStackLang.Parser.process_tree(tree)
    IO.puts "\nFinal state"
    IO.inspect state, pretty: true
  end
  
  def main(args) do
    filename = Enum.fetch!(args, 0)

    IO.puts "Parsing #{filename}"
    text = File.read!(filename)

    {:ok, tokens, line} = :cloud_stack_lang_lexer.string(String.to_charlist(text))
    IO.puts "Parsed #{filename}, stopped at line #{line}"
    IO.puts "\nTokens:"
    IO.inspect tokens, pretty: true

    process_parse(:cloud_stack_lang_parser.parse(tokens))
  end
end
