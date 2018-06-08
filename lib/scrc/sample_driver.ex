defmodule Scrc.SampleDriver do
  @moduledoc """
  SampleDriver implements a sample driver based on the [snakeoil](http://xed.ch/project/snakeoil/index.html) example driver.
  It's not fast, it's not nice but it does make it around the track.
  """

  use Scrc.Driver
  alias Scrc.{InitData, SensorData, ActorData}

  def scrc_init(state) do
    {
      :ok,
      state,
      driver_name(),
      focus_angles()
    }
  end

  def scrc_drive(%{sensor_data: sensor_data, actor_data: old_actor_data} = state) do

    actor_data = with target_speed = 100,
                      speed_x = sensor_data.speed_x,
                      acceleration = old_actor_data.acceleration,
                      # speed_y = sensor_data.speed_y,
                      # speed_z = sensor_data.speed_z,
                      {wsv_fl, wsv_fr, wsv_rl, wsv_rr} = sensor_data.wheel_spin_velocity
      do
      # Steer To Corner
      steer = sensor_data.angle * 10 / :math.pi
      # Steer To Center
      steer = steer - sensor_data.track_position * 0.10

      # Throttle Control
      acceleration = if speed_x < (target_speed - (steer * 50)), do: acceleration + 0.1, else: acceleration - 0.1
      acceleration = if speed_x < 10, do: acceleration + (1 / (speed_x + 0.1)), else: acceleration

      # Traction Control System
      acceleration = if (((wsv_rl + wsv_rr) - (wsv_fl + wsv_fr)) > 5),
                        do: acceleration - 0.2, else: acceleration

      # Automatic Transmission
      gear = cond do
        speed_x > 170 -> 6
        speed_x > 140 -> 5
        speed_x > 110 -> 4
        speed_x > 80 -> 3
        speed_x > 50 -> 2
        true -> 1
      end

      ActorData.clip(
        %ActorData{
          old_actor_data |
          acceleration: acceleration,
          brake: 0.0,
          clutch: 0.0,
          gear: gear,
          steer: steer,
          focus: 0.0,
          meta: 0
        }
      )
    end
    {:ok, %{state | actor_data: actor_data}}

  end

  defp driver_name(), do: "SCR"

  defp focus_angles(),
       do: [
         -45.0,
         -19.0,
         -12.0,
         -7.0,
         -4.0,
         -2.5,
         -1.7,
         -1.0,
         -0.5,
         0.0,
         0.5,
         1.0,
         1.7,
         2.5,
         4.0,
         7.0,
         12.0,
         19.0,
         45.0
       ]

end
