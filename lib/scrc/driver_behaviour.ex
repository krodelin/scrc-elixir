defmodule Scrc.DriverBehaviour do
  @moduledoc false

  alias Scrc.{SensorData, ActorData}


  @callback scrc_init(%{}) :: {:ok, %{}, String.t, [float()]}
  @callback scrc_drive(%{}) :: {:ok, %{}}

end
