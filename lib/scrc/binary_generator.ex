defmodule Scrc.BinaryGenerator do

  def generate(payload, payload_prefix, payload_fields) do

    prefix = case payload_prefix do
      nil ->
        ""
      {key, type, _}
      ->
        generate_value(Map.get(payload, key), type)
    end

    fields = (payload_fields
              |> Enum.reverse
              |> Enum.map(fn field -> do_generate(field, payload) end)
              |> Enum.join)

    prefix <> fields
  end


  defp do_generate({name, key, type, _}, payload),
       do: "(#{name} #{generate_value(Map.get(payload, key), type)})"

  defp generate_value(value, :float), do: generate_float_value(value)

  defp generate_value(list, [:float]), do: generate_float_values(list)

  defp generate_value(list, {:float}), do: generate_float_values(list)

  defp generate_value(value, :integer), do: generate_integer_value(value)

  defp generate_value(value, :string), do: value

  defp generate_float_value(value) do
    value
    |> :erlang.float_to_binary([{:decimals, 10}, :compact])
  end

  defp generate_float_values(list) when is_list(list) do
    list
    |> Enum.map(&generate_float_value/1)
    |> Enum.join(" ")
  end

  defp generate_float_values(tuple) when is_tuple(tuple) do
    tuple
    |> Tuple.to_list
    |> generate_float_values
  end

  defp generate_integer_value(value) do
    value
    |> Integer.to_string
  end

end
