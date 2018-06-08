defmodule Scrc.SensorData do
  @moduledoc """
  scrc.SensorData provides functions and the structure for SCRC sensor data.
  """

  @doc """
  ## Examples

  """

  use Scrc.Mapper
  require Logger

  defstruct angle: 0.0,
            current_lap_time: 0.0,
            damage: 0,
            distance_from_start: 0.0,
            distance_raced: 0.0,
            fuel: 0.0,
            gear: 0,
            last_lap_time: 0.0,
            opponents: [
              200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0,
              200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0,
              200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0,
              200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0
            ],
            race_position: 0,
            rpm: 0,
            speed_x: 0.0,
            speed_y: 0.0,
            speed_z: 0.0,
            acceleration_x: 0.0,
            acceleration_y: 0.0,
            acceleration_z: 0.0,
            track: [
              0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
              0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
              0.0, 0.0, 0.0, 0.0, 0.0, 0.0
            ],
            track_position: 0.0,
            wheel_spin_velocity: {0.0, 0.0, 0.0, 0.0},
            z: 0.0,
            focus: {-1.0, -1.0, -1.0, -1.0, -1.0} #, timestamp: 0

  field "angle", :angle, :float
  field "curLapTime", :current_lap_time, :float
  field "damage", :damage, :integer
  field "distFromStart", :distance_from_start, :float
  field "distRaced", :distance_raced, :float
  field "fuel", :fuel, :float
  field "gear", :gear, :integer
  field "lastLapTime", :last_lap_time, :float
  field "opponents", :opponents, [:float]
  field "racePos", :race_position, :integer
  field "rpm", :rpm, :float
  field "speedX", :speed_x, :float
  field "speedY", :speed_y, :float
  field "speedZ", :speed_z, :float
  field "track", :track, [:float]
  field "trackPos", :track_position, :float
  field "wheelSpinVel", :wheel_spin_velocity, {:float}
  field "z", :z, :float
  field "focus", :focus, {:float}


  # def process(%__MODULE__{} = data) do
  #   Map.put(data, :timestamp, :erlang.system_time(1_000_000_000))
  # end

  def update_deltas(%__MODULE__{} = new_data, %__MODULE__{} = old_data) do
    # delta_t = max(0.001, (new_data.timestamp - old_data.timestamp) / 1_000_000_000)
    delta_t = max(1 / 50, new_data.current_lap_time - old_data.current_lap_time)
    %{
      new_data |
      acceleration_x: (new_data.speed_x - old_data.speed_x) / 3.6 / delta_t,
      acceleration_y: (new_data.speed_y - old_data.speed_y) / 3.6 / delta_t,
      acceleration_z: (new_data.speed_z - old_data.speed_z) / 3.6 / delta_t
    }
  end

  def update_deltas(%__MODULE__{} = new_data, nil) do
    new_data
  end


end
