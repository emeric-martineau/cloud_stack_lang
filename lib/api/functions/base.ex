defmodule CloudStackLang.Functions.Base do
  def get_map() do
    # <function name as atom> => type, [args type], return type, function
    #
    # type       : :fct or :manager
    # args type  : array with list of arg type of function
    # return type: type of return
    # function   : the function
    #
    # type list:
    #   :int
    #   :float
    #   :string
    #   :array
    #   :map
    #   :void
    #
    # The function must return {:ok, value} or {:error, msg}
    %{
      :base64 => %{
        :decode => {:fct, [:string], :string, &Base.decode64/1},
        :encode => {:fct, [:string], :string, &encode64/1},
      },
      :log => %{
        :debug => {:fct, [:string], :void, &debug/1},
        :info => {:fct, [:string], :void, &info/1},
        :warning => {:fct, [:string], :void, &warning/1},
        :error => {:fct, [:string], :void, &error/1},
      }
    }
  end

  defp decode64(s) do
    case Base.decode64(s) do
      {:ok, r} -> {:string, r}
      v -> v
    end
  end

  defp encode64(s) do
    {:string, Base.encode64(s)}
  end

  defp debug(s) do
    IO.puts("DEBUG: #{s}")
    {:void}
  end

  defp info(s) do
    IO.puts("INFO: #{s}")
    {:void}
  end

  defp warning(s) do
    IO.puts("WARN: #{s}")
    {:void}
  end

  defp error(s) do
    IO.puts("ERROR: #{s}")
    {:void}
  end
end