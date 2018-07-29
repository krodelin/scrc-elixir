defmodule Scrc.Proxy do


  use GenServer
  require Logger

  alias Scrc.{Server, Client}

  def restart_race(proxy) do
    GenServer.cast(proxy, :restart_race)
  end
  # GenServer callbacks

  def start_link(state, _opts \\ []) do
    GenServer.start_link(__MODULE__, state, name: :proxy)
  end

  def init(%{endpoint: endpoint, port: port}) do
    {:ok, server} = Server.start_link(%{simulation: self(), port: port})
    {:ok, client} = Client.start_link(%{driver: self(), endpoint: endpoint})
    {
      :ok,
      %{
        server: server,
        client: client,
        init_data: nil,
        sensor_data: nil,
        actor_data: nil,
        attack_level: 0
      }
    }
  end

  def handle_cast({:set_client, client}, state) do
    {:noreply, %{state | client: client}}
  end

  def handle_cast({:request_init_data}, %{client: client, init_data: init_data} = state) do
    Client.send_init_data(client, init_data)
    {:noreply, state}
  end

  def handle_cast({:handle_init_data, init_data}, %{client: client} = state) do
    Client.start_race(client)
    {:noreply, %{state | init_data: init_data}}
  end

  def handle_cast(:handle_identified, %{server: server} = state) do
    Server.send_identified(server)
    {:noreply, state}
  end

  def handle_cast(:handle_shutdown, %{server: server} = state) do
    Server.send_shutdown(server)
    {:noreply, state}
  end

  def handle_cast(:handle_restart, %{server: server} = state) do
    Server.send_restart(server)
    {:noreply, state}
  end

  def handle_cast(
        {:handle_sensor_data, new_sensor_data},
        %{sensor_data: old_sensor_data, server: server, attack_level: level} = state
      ) do
    updated_sensor_data = new_sensor_data
                          |> Scrc.SensorData.update_deltas(old_sensor_data)
                          |> compromise_sensor_data(level)
    Server.send_sensor_data(server, updated_sensor_data)
    {:noreply, %{state | sensor_data: updated_sensor_data}}
  end

  def handle_cast({:handle_actor_data, actor_data}, %{client: client} = state) do

    Client.send_actor_data(client, actor_data)
    {:noreply, %{state | actor_data: actor_data}}
  end

  def handle_cast(:restart_race, %{client: client} = state) do
    Client.restart_race(client)
    {:noreply, state}
  end

  def handle_cast({:attack, level}, state) do
    {:noreply, %{state | attack_level: level}}
  end

  def attack(level) do
    GenServer.cast(:proxy, {:attack, level})
  end

  def compromise_sensor_data(data, level) do
    if level > 1 do
      new_track = Enum.reverse(data.track)
      %Scrc.SensorData{data | track: new_track}
    else
      data
    end
  end
end