defmodule Scrc.ActorData do
  @moduledoc """
  ActorData provides struct for SCRC actor data.
  """

  use Scrc.Mapper

  @type t :: %Scrc.ActorData{
               gear: integer,
               steer: float,
               brake: float,
               clutch: float,
               acceleration: float,
               focus: float,
               meta: integer
             }

  defstruct gear: 1,
            steer: 0.0,
            brake: 0.0,
            clutch: 0.0,
            acceleration: 0.2,
            focus: 0.0,
            meta: 0

  field "accel", :acceleration, :float, clip: {0.0, 1.0}
  field "brake", :brake, :float, clip: {0.0, 1.0}
  field "clutch", :clutch, :float, clip: {0.0, 1.0}
  field "gear", :gear, :integer, clip: [-1, 0, 1, 2, 3, 4, 5, 6], default: 0
  field "steer", :steer, :float, clip: {-1.0, 1.0}
  field "focus", :focus, :float, clip: {-90.0, 90.0}
  field "meta", :meta, :integer, clip: [0, 1], default: 0

end
