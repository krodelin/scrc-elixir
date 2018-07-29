defmodule Scrc.Client do
  @moduledoc """
  Client implements boilerplate code for implementing an SCRC client.
  It forwards the domain specific calls to it's `driver`.
  """

  use GenServer
  require Logger
  alias Scrc.{Driver, InitData, SensorData, ActorData}

  @timeout 10_000

  @type option :: {:endpoint, Scrc.Server.endpoint} | {:driver, pid()}
  @type options :: [option]

  # Public interface

  @doc """
  Start the race

  Send initial data to server and start to wait for data
  """
  @spec start_race(pid) :: :ok
  def start_race(client) do
    GenServer.cast(client, :connect_race)
  end

  @doc """
    Request a race restart from server.
  """
  @spec restart_race(pid) :: :ok
  def restart_race(client) do
    GenServer.cast(client, :restart_race)
  end

  @doc """
  Send initialization (focus) data to server.
  """
  @spec send_init_data(pid, Scrc.InitData.t) :: :ok
  def send_init_data(client, data) do
    GenServer.cast(client, {:send_init_data, data})
  end

  @doc """
  Send actor command to server.
  """
  @spec send_actor_data(pid, Scrc.ActorData.t) :: :ok
  def send_actor_data(client, data) do
    GenServer.cast(client, {:send_actor_data, data})
  end

  # GenServer callbacks

  def start_link(args, opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  @doc """
    Start a new client instance to the specified endpoint. Use provided driver process for controlling.
  """
  @spec init(options) :: map()
  def init(args) do
    %{endpoint: {host, port}, driver: driver} = Enum.into(args, %{})
    Driver.set_client(driver, self())
    case  Scrc.Helper.gethostbyname(host) do
      {:ok, address} -> {
                          :ok,
                          %{
                            endpoint: {address, port},
                            socket: new_socket(),
                            driver: driver,
                            connection_state: :disconnected
                          }
                        }
      {:error, message} -> {:stop, message}
    end

  end

  def handle_cast(:connect_race, %{driver: driver} = state) do
    Driver.request_init_data(driver)
    {:noreply, %{state | connection_state: :connecting}, @timeout}
  end

  def handle_cast(:restart_race, %{connection_state: :connect_raceed} = state) do
    {:noreply, %{state | connection_state: :disconnecting}}
  end

  def handle_cast({:send_init_data, data}, %{socket: socket, endpoint: endpoint} = state) do
    data
    |> InitData.to_binary()
    |> send(socket, endpoint)
    {:noreply, state, @timeout}
  end

  def handle_cast(
        {:send_actor_data, data},
        %{socket: socket, endpoint: endpoint, connection_state: connection_state} = state
      ) do
    data
    |> update_meta(connection_state)
    |> ActorData.to_binary
    |> send(socket, endpoint)
    {:noreply, state}
  end

  def handle_info(:timeout, %{driver: driver} = state) do
    Driver.request_init_data(driver)
    {:noreply, %{state | connection_state: :connecting}, @timeout}
  end

  def handle_info({:udp, _socket, _host, _port, data}, state) do
    handle_udp_data(String.trim(data, <<0>>), state)
  end

  # Private functions

  defp handle_udp_data("***identified***", %{driver: driver} = state) do
    Driver.handle_identified(driver)
    {:noreply, %{state | connection_state: :connect_raceed}, @timeout}
  end

  defp handle_udp_data("***shutdown***", %{driver: driver} = state) do
    Driver.handle_shutdown(driver)
    {:noreply, %{state | connection_state: :disconnected}}
  end

  defp handle_udp_data("***restart***", %{driver: driver} = state) do
    Driver.handle_restart(driver)
    {:noreply, %{state | connection_state: :connecting}, @timeout}
  end

  defp handle_udp_data(data, %{driver: driver} = state) do
    Driver.handle_sensor_data(driver, SensorData.from_binary(data))
    {:noreply, state}
  end

  defp new_socket() do
    socket = Socket.UDP.open!(0, mode: :active)
    Socket.UDP.process!(socket, self())
    socket
  end

  defp update_meta(actor_data, connection_state) do
    meta = if connection_state == :disconnecting, do: 1, else: 0
    Map.put(actor_data, :meta, meta)
  end

  defp send(binary, socket, endpoint) do
    Socket.Datagram.send!(socket, binary, endpoint)
  end

end