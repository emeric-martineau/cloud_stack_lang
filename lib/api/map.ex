defmodule CloudStackLang.Map do
  @moduledoc """
  This module contains all routine to help access to map value with key.

    ## Examples

      iex> CloudStackLang.Map.reduce([{:string, 1, "c"}], {:map, %{"c" => {:int, 1}}})
      {:int, 1}

      iex> CloudStackLang.Map.reduce([{:string, 1, "c"}], nil)
      {:error, 1, "Trying get a value with key 'c' on nil value"}

      iex> CloudStackLang.Map.reduce([{:string, 1, "c"}], 1)
      {:error, 1, "Trying get a value with key 'c' on non-map value"}
  """

  def reduce(access_keys, {:map, state}) do
    [first_key | keys] = access_keys
    {_type, _line, key} = first_key

    reduce(keys, state[key])
  end

  def reduce(access_keys, nil) do
    [first_key | _keys] = access_keys
    {_type, line, key} = first_key

    {:error, line, "Trying get a value with key '#{key}' on nil value"}
  end

  def reduce([], state) do
    state
  end

  def reduce(access_keys, _state) do
    [first_key | _keys] = access_keys
    {_type, line, key} = first_key

    {:error, line, "Trying get a value with key '#{key}' on non-map value"}
  end
end
