defmodule Scrc do
  @moduledoc """
  SCRC
  """

  require Logger

  def start_client(endpoint) do
    # Logger.configure(level: :info)
    {:ok, driver} = Scrc.SampleDriver.start_link()
    {:ok, client} = Scrc.Client.start_link(%{driver: driver, endpoint: endpoint})
    :ok = Scrc.Client.start_race(client)
    {:ok, [driver: driver, client: client]}
  end

  # clear ; recompile ; Scrc.start_proxy({"192.168.10.24", 3001}, 4001)
  def start_proxy(endpoint \\ {"127.0.0.1", 3001}, port \\ 4001) do
    Logger.configure(level: :info)
    {:ok, proxy} = Scrc.Proxy.start_link(%{endpoint: endpoint, port: port})
  end

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

  def do_parse_number(string) do
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





end
