defmodule Scrc.Server do
  @moduledoc false



  use GenServer
  require Logger
  alias Scrc.{InitData, SensorData, ActorData}

  # Public interface

  def send_identified(server) do
    GenServer.cast(server, :send_identified)
  end

  def send_shutdown(server) do
    GenServer.cast(server, :send_shutdown)
  end

  def send_restart(server) do
    GenServer.cast(server, :send_restart)
  end

  def send_sensor_data(server, sensor_data) do
    GenServer.cast(server, {:send_sensor_data, sensor_data})
  end



  # GenServer callbacks

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

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