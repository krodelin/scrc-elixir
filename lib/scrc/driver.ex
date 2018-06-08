defmodule Scrc.Driver do
  @moduledoc """
    Driver implements the framework to write custom drivers.
    Simply `use` this module and implement `scrc_init` and `scrc_drive`.
  """
  @type name :: String.t

  # Public interface

  @doc """
    Set the owning client.
  """
  @spec set_client(pid, pid) :: :ok
  def set_client(driver, client) do
    GenServer.cast(driver, {:set_client, client})
  end

  @doc """
    The client requests the initialization data.
  """
  @spec request_init_data(pid) :: :ok
  def request_init_data(driver) do
    GenServer.cast(driver, {:request_init_data})
  end

  @doc """
    The client recieved new sensor data for the driver to handle.
  """
  @spec handle_sensor_data(pid, Scrc.SensorData.t) :: :ok
  def handle_sensor_data(driver, sensor_data) do
    # Logger.debug(fn -> "Scrc.Driver.handle_sensor_data(driver, sensor_data)" end)
    GenServer.cast(driver, {:handle_sensor_data, sensor_data})
  end

  @doc """
    The client recieved identified payload for the driver to handle.
  """
  @spec handle_identified(pid) :: :ok
  def handle_identified(driver) do
    GenServer.cast(driver, :handle_identified)
  end

  @doc """
    The client recieved restart payload for the driver to handle.
  """
  @spec handle_restart(pid) :: :ok
  def handle_restart(driver) do
    GenServer.cast(driver, :handle_restart)
  end

  @doc """
    The client recieved shutdown payload for the driver to handle.
  """
  @spec handle_shutdown(pid) :: :ok
  def handle_shutdown(driver) do
    GenServer.cast(driver, :handle_shutdown)
  end

  defmacro __using__(_) do
    quote do
      require Logger
      import unquote(__MODULE__)
      use GenServer
      @behaviour Scrc.DriverBehaviour
      alias Scrc.{Client, InitData, SensorData, ActorData}

      # Public interface

      def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, opts)
      end

      # GenServer callbacks
      def init(_args) do
        {:ok, %{client: nil, init_data: InitData.new(), sensor_data: SensorData.new(), actor_data: ActorData.new()}}
      end

      def handle_cast({:set_client, client}, state) do
        {:noreply, %{state | client: client}}
      end

      def handle_cast({:request_init_data}, %{client: client} = state) do
        {:ok, state, driver_name, focus_angles} = scrc_init(state)
        init_data = InitData.new(%{name: driver_name, angles: focus_angles})
        Client.send_init_data(client, init_data)
        {:noreply, %{state | init_data: init_data}}
      end

      def handle_cast({:handle_sensor_data, sensor_data}, %{client: client} = state) do
        {:ok, %{actor_data: actor_data} = new_state} = state
                                                       |> update_sensor_data(sensor_data)
                                                       |> scrc_drive()
        Client.send_actor_data(client, actor_data)
        {:noreply, new_state}
      end

      # Private functions

      defp update_sensor_data(%{sensor_data: old_sensor_data} = state, new_sensor_data) do
        updated_sensor_data = new_sensor_data
                              |> SensorData.update_deltas(old_sensor_data)
        %{state | sensor_data: updated_sensor_data}
      end

    end
  end

end

