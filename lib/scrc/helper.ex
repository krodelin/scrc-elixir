defmodule Scrc.Helper do
  @moduledoc """
  This module implements several helper methods.
  """

  @doc """
    Parse a string into a number

    This implementation is much slower than native Erlang/Elixir versions but is also more forgiving.
    It's especially usefull as the client/server languages in SCRC provide numbers in a various non-standard ways.
  """
  def parse_number(string) do
    %{
      rest: rest,
      sign: sign,
      integral: integral,
      fractional: fractional
    } = do_parse_number(string)
    number = (integral + fractional) * sign
    {number, rest}
  end

  defp do_parse_number(string) do
    %{
      rest: string,
      sign: 1,
      integral: 0,
      fractional: 0.0
    }
    |> do_parse_sign
    |> do_parse_integral
    |> do_parse_fractional
  end

  defp do_parse_sign(%{rest: "-" <> string} = acc), do: %{acc | rest: string, sign: -1}
  defp do_parse_sign(%{rest: "+" <> string} = acc), do: %{acc | rest: string, sign: 1}
  defp do_parse_sign(acc), do: acc

  defp do_parse_integral(%{rest: rest} = acc) do
    case Integer.parse(rest) do
      {number, rest} -> %{acc | rest: rest, integral: number}
      :error -> acc
    end
  end

  defp do_parse_fractional(%{rest: "." <> rest} = acc) do
    case Float.parse("0." <> rest) do
      {number, rest} ->
        %{acc | rest: rest, fractional: number}
      :error -> acc
    end
  end

  defp do_parse_fractional(acc) do
    acc
  end

  def gethostbyname(hostname) do
    case Socket.Host.by_name(hostname) do
      {:ok, socket_host} ->
        [address | _] = socket_host.list
        {:ok, address}
      {:error, message} -> {:error, message}
    end
  end
end
