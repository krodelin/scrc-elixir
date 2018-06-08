defmodule Scrc.Mapper do
  @moduledoc false

  defmacro field(name, key, type, opts \\ []) do
    quote  do
      def parse_value(unquote(name), list),
          do: {unquote(key), Scrc.DataParser.parse(list, unquote(type), unquote(opts))}
      @payload_fields  {unquote(name), unquote(key), unquote(type), unquote(opts)}
    end
  end

  defmacro prefix(key, type, opts \\ []) do
    quote  do
      def parse_prefix(value),
          do: {unquote(key), value}
      @payload_prefix  {unquote(key), unquote(type), unquote(opts)}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def to_binary(%_{} = data), do: Scrc.BinaryGenerator.generate(data, @payload_prefix, @payload_fields)

      def clip(data), do: Scrc.DataClipper.clip(data, @payload_fields)

      def new(values \\ %{}) do
        %__MODULE__{}
        |> Map.merge(values)
        |> __MODULE__.process()
      end

    end
  end

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      @before_compile unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :payload_fields, accumulate: true, persist: false)
      Module.register_attribute(__MODULE__, :payload_prefix, accumulate: false, persist: false)
      Module.put_attribute(__MODULE__, :payload_prefix, nil)



      def from_binary(binary) when is_binary(binary) do
        binary
        |> String.trim(<<0>>)
        |> String.split(["(", ")"], trim: true)
        |> Enum.map(&parse_field/1)
        |> Enum.into(%{})
        |> __MODULE__.new()
      end

      defp parse_field(string) do
        with [key | value] = String.split(string, [" "], trim: true) do
          case value do
            [] ->
              parse_prefix(key)
            _ ->
              parse_value(key, value)
          end
        end
      end

      defp parse_value(key, list), do: raise("Unknown key #{inspect(key)} = #{inspect(list)}")
      defp parse_prefix(value), do: raise("Unknown prefix #{value}")

      def process(data), do: data

      defoverridable [parse_value: 2, parse_prefix: 1, process: 1]
    end

  end



end


