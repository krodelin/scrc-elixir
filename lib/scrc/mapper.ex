defmodule Scrc.Mapper do
  @moduledoc """
  Mapper implements a custom DSL to map an SCRC Binary string to typed native fields and vice versa.

  ```
  defmodule Scrc.InitData do
    use Scrc.Mapper

    defstruct name: "SCR",
              angles: [0, 0]

    prefix :name, :string
    field "init", :angles, [:float]
  end
  ```

      iex> data = Scrc.InitData.from_binary("SCR(init 0 2)")
      %Scrc.InitData{angles: [0.0, 2.0], name: "SCR"}

      iex> Scrc.InitData.to_binary(data)
      "SCR(init 0.0 2.0)"
  """

  @type type :: :float | :integer | [:float] | [:integer]
  @type option :: {:clip, {number, number}} | {:clip, [number]} | {:default, number}
  @type options :: [option]
  @type payload_field :: {String.t, atom, type, options}
  @type payload_fields :: [payload_field]

  @doc """
    Declare a field with name (external and internal, type and options.

    * `name` - Field specifier how it appears in the binary
    * `key` - Field specifier to use in the struct
    * `type` - Can be `:float` or `:integer`. Also allows lists using `[:float]` and `[:integer]`
    * `opts` - Allows to specifiy clipping and default values
      - `default: value` - Specify default value
      - `clip: {min, max}` - Clips the number to min-max
      - `clip: [val1, val2, ..., valn]` - Clips the number to one of the values - `nil` if not in the list
  """
  @spec field(String.t, atom, type, options) :: any
  defmacro field(name, key, type, opts \\ []) do
    quote  do
      defp parse_value(unquote(name), list),
           do: {unquote(key), Scrc.DataParser.parse(list, unquote(type), unquote(opts))}
      @payload_fields  {unquote(name), unquote(key), unquote(type), unquote(opts)}
    end
  end


  @doc """
    Declare a prefix field with name internal and type (String in most cases).

    * `key` - Field specifier to use in the struct
    * `type` - Ignored
  """
  @spec prefix(atom, :string, any) :: any
  defmacro prefix(key, type, opts \\ []) do
    quote  do
      defp parse_prefix(value),
           do: {unquote(key), value}
      @payload_prefix  {unquote(key), unquote(type), unquote(opts)}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @doc """
        Create binary from struct according to field/prefix specification.
      """
      @spec to_binary(__MODULE__.t) :: binary
      def to_binary(%_{} = data), do: Scrc.BinaryGenerator.generate(data, @payload_prefix, @payload_fields)

      @doc """
        Clip values according to field specification
      """
      @spec clip(__MODULE__.t) :: __MODULE__.t
      def clip(data), do: Scrc.DataClipper.clip(data, @payload_fields)

      @doc """
        Create new Struct based on values. Apply post-processing (if needed).
      """
      @spec new(map) :: __MODULE__.t
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

      @doc """
        Parse binary according to field/prefix specification and return Struct
      """
      @spec from_binary(binary) :: __MODULE__.t
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

      @doc """
        Callback for postprocessing after creation from binary.

        By default simply return the passed data
      """
      @spec process(__MODULE__.t) :: __MODULE__.t
      def process(data), do: data

      defoverridable [parse_value: 2, parse_prefix: 1, process: 1]
    end

  end



end


