defmodule Simulation do
  @moduledoc """
    Simulation implements the framework to write custom simulations.
  """

  use GenServer


  # Public interface

  @doc """
    The server recieved new initialization data for the simulation to handle.
  """
  @spec handle_init_data(pid, Scrc.InitData.t) :: :ok
  def handle_init_data(simulation, init_data) do
    GenServer.cast(simulation, {:handle_init_data, init_data})
  end

  @doc """
    The server recieved new actor data for the simulation to handle.
  """
  @spec handle_actor_data(pid, Scrc.ActorData.t) :: :ok
  def handle_actor_data(simulation, actor_data) do
    GenServer.cast(simulation, {:handle_actor_data, actor_data})
  end

  # GenServer callbacks

  def init(args) do
    {:ok, args}
  end


end