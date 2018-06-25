defmodule Scrc.Server do
  @moduledoc """
  Server implements boilerplate code for implementing an SCRC Server.
  It forwards the domain specific calls to it's `simulation`.
  """

  use GenServer
  require Logger
  alias Scrc.{InitData, SensorData, ActorData}

  @typedoc """
  Endpoint consists of a hostname (or IP) and port combination.
  """
  @type endpoint :: {endpoint_host, endpoint_port}
  @typedoc """
  A hostname or IP Address.
  """
  @type endpoint_host :: String.t
  @typedoc """
  A TCP Port number (0-65535)
  """
  @type endpoint_port :: integer

  # Public interface

  @doc """
    Send identified payload to client.
  """
  @spec send_identified(pid) :: :ok
  def send_identified(server) do
    GenServer.cast(server, :send_identified)
  end

  @doc """
    Send shutdown payload to client.
  """
  @spec send_shutdown(pid) :: :ok
  def send_shutdown(server) do
    GenServer.cast(server, :send_shutdown)
  end

  @doc """
    Send restart payload to client.
  """
  @spec send_restart(pid) :: :ok
  def send_restart(server) do
    GenServer.cast(server, :send_restart)
  end

  @doc """
    Send sensor payload to client.
  """
  @spec send_sensor_data(pid, Scrc.SensorData.t) :: :ok
  def send_sensor_data(server, sensor_data) do
    GenServer.cast(server, {:send_sensor_data, sensor_data})
  end



  # GenServer callbacks

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  @doc """
    Initialize the server with the given `simulation`. Listen on `port`.
  """
  @spec init(%{simulation: pid, port: endpoint_port}) :: {
                                                           :ok,
                                                           %{simulation: pid, socket: any, endpoint: endpoint}
                                                         }
  def init(%{simulation: simulation, port: port}) do
    {
      :ok,
      %{
        simulation: simulation,
        socket: new_socket(port),
        endpoint: nil
      }
    }
  end

  def handle_cast(:send_identified, %{socket: socket, endpoint: endpoint} = state) do
    send("***identified***", socket, endpoint)
    {:noreply, state}
  end

  def handle_cast(:send_shutdown, %{socket: socket, endpoint: endpoint} = state) do
    send("***shutdown***", socket, endpoint)
    {:noreply, state}
  end

  def handle_cast(:send_restart, %{socket: socket, endpoint: endpoint} = state) do
    send("***restart***", socket, endpoint)
    {:noreply, state}
  end

  def handle_cast({:send_sensor_data, sensor_data}, %{socket: socket, endpoint: endpoint} = state) do
    sensor_data
    |> SensorData.to_binary
    |> send(socket, endpoint)
    {:noreply, state}
  end

  def handle_info({:udp, _socket, host, port, data}, state) do
    handle_udp_data({host, port}, String.trim(data, <<0>>), state)
  end

  defp handle_udp_data(endpoint, data, %{simulation: simulation} = state) do
    if Regex.match?(~r/\(init /, data) do
      init_data = InitData.from_binary(data)
      Simulation.handle_init_data(simulation, init_data)
      {:noreply, %{state | endpoint: endpoint}}
    else
      actor_data = ActorData.from_binary(data)
      Simulation.handle_actor_data(simulation, actor_data)
      {:noreply, state}
    end
  end

  # Private functions

  defp new_socket(port) do
    socket = Socket.UDP.open!(port, mode: :active)
    Socket.UDP.process!(socket, self())
    socket
  end

  defp send(binary, socket, endpoint) do
    Socket.Datagram.send!(socket, binary, endpoint)
  end
end