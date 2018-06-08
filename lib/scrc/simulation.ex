defmodule Simulation do
  @moduledoc false



  use GenServer


  # Public interface

  def handle_init_data(simulation, init_data) do
    GenServer.cast(simulation, {:handle_init_data, init_data})
  end

  def handle_actor_data(simulation, actor_data) do
    GenServer.cast(simulation, {:handle_actor_data, actor_data})
  end

  # GenServer callbacks


end