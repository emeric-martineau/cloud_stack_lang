defmodule CloudStackLang.Providers do
  @moduledoc ~S"""
  This module return list of available provider.
  """
  def get_list(), do: [CloudStackLang.Providers.AWS]
end
