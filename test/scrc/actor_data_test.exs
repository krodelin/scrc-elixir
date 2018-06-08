defmodule ActorDataTest do
  @moduledoc false

  use ExUnit.Case
  alias Scrc.ActorData

  setup  do

    binary = "(accel 0.2)(brake 0.1)(clutch 0.5)(gear 1)(steer -0.001)(focus -10.0)(meta 0)"

    data = ActorData.new(
      %{
        gear: 1,
        steer: -0.001,
        brake: 0.1,
        clutch: 0.5,
        acceleration: 0.2,
        focus: -10.0,
        meta: 0
      }
    )
    [binary: binary, data: data]
  end

  test "convert binary to data", context do
    parsed = ActorData.from_binary(context[:binary])

    assert parsed.acceleration == 0.2
    assert parsed.brake == 0.1
    assert parsed.clutch == 0.5
    assert parsed.gear == 1
    assert parsed.steer == -0.001
    assert parsed.focus == -10
    assert parsed.meta == 0

  end

  test "convert data to binary", context  do
    assert ActorData.to_binary(ActorData.new(context[:data])) == context[:binary]
  end

  test "clipping" do

    actor_data = ActorData.new(
                   %{
                     gear: 7,
                     steer: -2.0,
                     brake: 2.0,
                     clutch: 2.0,
                     acceleration: 2.0,
                     focus: -100.0,
                     meta: 10
                   }
                 )
                 |> ActorData.clip()

    assert actor_data.acceleration == 1.0
    assert actor_data.brake == 1.0
    assert actor_data.clutch == 1.0
    assert actor_data.gear == 0
    assert actor_data.steer == -1.0
    assert actor_data.focus == -90.0
    assert actor_data.meta == 0
  end
end

