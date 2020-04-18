#
# Copyright 2020 Cloud Stack Lang Contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
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
        :decode => {:fct, [:string], &decode64/1},
        :encode => {:fct, [:string], &encode64/1}
      },
      :log => %{
        :debug => {:fct, [:string], &debug/1},
        :info => {:fct, [:string], &info/1},
        :warning => {:fct, [:string], &warning/1},
        :error => {:fct, [:string], &error/1}
      }
    }
  end

  defp decode64(s) do
    case Base.decode64(s) do
      {:ok, r} -> {:string, r}
      v -> v
    end
  end

  defp encode64(s), do: {:string, Base.encode64(s)}

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
