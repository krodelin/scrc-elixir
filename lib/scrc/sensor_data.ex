defmodule Scrc.SensorData do
  @moduledoc """
  SensorData provides the struct for SCRC sensor data.
  """

  use Scrc.Mapper

  @type t :: %Scrc.SensorData{
               angle: :float,
               current_lap_time: :float,
               damage: :integer,
               distance_from_start: :float,
               distance_raced: :float,
               fuel: :float,
               gear: :integer,
               last_lap_time: :float,
               opponents: [:float,],
               race_position: :integer,
               rpm: :integer,
               speed_x: :float,
               speed_y: :float,
               speed_z: :float,
               acceleration_x: :float,
               acceleration_y: :float,
               acceleration_z: :float,
               track: [:float,],
               track_position: :float,
               wheel_spin_velocity: {:float, :float, :float, :float, },
               z: :float,
               focus: {:float, :float, :float, :float, :float}
             }

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
            focus: {-1.0, -1.0, -1.0, -1.0, -1.0}

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


  @doc """
  Update fields based on current and previous data
  """
  @spec update_deltas(__MODULE__.t, __MODULE__.t) :: __MODULE__.t
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
