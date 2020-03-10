defmodule CloudStackLang.Functions.BaseWrapper do
  def encode64(s) do
    {:ok, Base.encode64(s)}
  end
end