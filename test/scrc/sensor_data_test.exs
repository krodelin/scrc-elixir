defmodule Scrc.SensorDataTest do
  @moduledoc false

  use ExUnit.Case
  alias Scrc.SensorData

  setup  do

    binary = "(angle 0.0245684)(curLapTime 83.016)(damage 0)(distFromStart 5759.1)(distRaced 0.0)(fuel 94.0)(gear 0)(lastLapTime 0.0)(opponents 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0 200.0)(racePos 1)(rpm 942.478)(speedX -0.00981201)(speedY -0.000454448)(speedZ -0.000144506)(track 7.33557 7.48059 7.87415 8.5848 9.75901 11.7102 15.1868 22.3954 43.1582 200.0 19.2827 10.1309 7.05919 5.55189 4.69456 4.17718 3.8689 3.70813 3.6676)(trackPos -0.333363)(wheelSpinVel -1.57439 1.80223 -1.57512 2.27044)(z 0.345255)(focus -1.0 -1.0 -1.0 -1.0 -1.0)"

    data = SensorData.new(
      %{
        angle: 0.0245684,
        current_lap_time: 83.016,
        damage: 0,
        distance_from_start: 5759.1,
        distance_raced: 0.0,
        focus: {-1.0, -1.0, -1.0, -1.0, -1.0},
        fuel: 94.0,
        gear: 0,
        last_lap_time: 0.0,
        opponents: [200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0,
          200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0,
          200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0,
          200.0, 200.0, 200.0, 200.0, 200.0],
        race_position: 1,
        rpm: 942.478,
        speed_x: -0.00981201,
        speed_y: -0.000454448,
        speed_z: -0.000144506,
        track: [7.33557, 7.48059, 7.87415, 8.5848, 9.75901, 11.7102, 15.1868, 22.3954,
          43.1582, 200.0, 19.2827, 10.1309, 7.05919, 5.55189, 4.69456, 4.17718, 3.8689,
          3.70813, 3.6676],
        track_position: -0.333363,
        wheel_spin_velocity: {-1.57439, 1.80223, -1.57512, 2.27044},
        z: 0.345255
      }
    )
    [binary: binary, data: data]
  end

  test "convert binary to data", context do

    data = SensorData.from_binary(context[:binary])

    assert data.angle == 0.0245684
    assert data.current_lap_time == 83.016
    assert data.damage == 0
    assert data.distance_from_start == 5759.1
    assert data.distance_raced == 0.0
    assert data.fuel == 94.0
    assert data.gear == 0
    assert data.last_lap_time == 0.0
    assert data.opponents == [
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0,
             200.0
           ]
    assert data.race_position == 1
    assert data.rpm == 942.478
    assert data.speed_x == -0.00981201
    assert data.speed_y == -0.000454448
    assert data.speed_z == -0.000144506
    assert data.track == [
             7.33557,
             7.48059,
             7.87415,
             8.5848,
             9.75901,
             11.7102,
             15.1868,
             22.3954,
             43.1582,
             200.0,
             19.2827,
             10.1309,
             7.05919,
             5.55189,
             4.69456,
             4.17718,
             3.8689,
             3.70813,
             3.6676
           ]
    assert data.track_position == -0.333363
    assert data.wheel_spin_velocity == {-1.57439, 1.80223, -1.57512, 2.27044}
    assert data.z == 0.345255
    assert data.focus == {-1.0, -1.0, -1.0, -1.0, -1.0}
  end

  test "convert data to binary", context do
    assert  SensorData.to_binary(SensorData.new(context[:data])) == context[:binary]
  end
end

