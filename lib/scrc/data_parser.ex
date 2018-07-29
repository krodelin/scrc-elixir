defmodule Scrc.DataParser do
  @moduledoc false
  # This is the DataParser module. It implements parsing of SCRC data into native types.

  @doc """
  Parse the provided list of strings into native types according to the specified type.
  """
  @spec parse([String.t], Scrc.Mapper.type, any) :: [number]
  def parse(list, :float, _opts), do: parse_float_value(list)

  def parse(list, [:float], _opts), do: parse_float_values(list)

  def parse(list, {:float}, _opts), do: List.to_tuple(parse_float_values(list))

  def parse(list, :integer, _opts), do: parse_integer_value(list)

  def parse(list, [:integer], _opts), do: parse_integer_values(list)

  def parse(_list, type, _opts), do: raise(ArgumentError, "Missing parse function for #{inspect(type)}")

  defp parse_float_value(list) do
    list
    |> parse_float_values
    |> List.first
  end

  defp parse_float_values(list) do
    list
    |> Enum.map(&to_number/1)
  end

  defp parse_integer_value(list) do
    list
    |> parse_integer_values
    |> List.first
  end

  defp parse_integer_values(list) do
    list
    |> Enum.map(&to_number/1)
    |> Enum.map(&Kernel.trunc/1)
  end

  defp to_number(string) when is_binary(string) do
    {float, _} = Scrc.Helper.parse_number(string)
    float
  end

end