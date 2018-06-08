defmodule Scrc.DriverBehaviour do
  @moduledoc """
  DriverBehaviour defines the functions to be implemented for custom drivers
  """

  @callback scrc_init(map) :: {:ok, map, Scrc.Driver.name, [float()]}
  @callback scrc_drive(%{sensor_data: Scrc.SensorData.t, actor_data: Scrc.ActorData.t}) :: {
                                                                                             :ok,
                                                                                             %{
                                                                                               actor_data:
                                                                                                 Scrc.ActorData.t
                                                                                             }
                                                                                           }

end
