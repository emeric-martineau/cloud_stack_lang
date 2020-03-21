defmodule CloudStackLang.Functions.Base do
  def get_map() do
    # <function name as atom> => [args type], return type, function, return fct transformer
    %{
      :base64 => %{
        :decode => {[:string], :string, &Base.decode64/1},
        :encode => {[:string], :string, &encode64/1},
      }
    }
  end

  defp encode64(s) do
    {:ok, Base.encode64(s)}
  end
end