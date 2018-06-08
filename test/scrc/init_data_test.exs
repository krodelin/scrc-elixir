defmodule InitDataTest do
  @moduledoc false

  use ExUnit.Case
  alias Scrc.InitData

  setup  do

    binary = "Driver1(init -45.0 -20.0 -12.0 -7.0 -4.0 -2.5 -1.7 -1.0 -0.5 0.0 0.5 1.0 1.7 2.5 4.0 7.0 12.0 20.0 45.0)"

    data = InitData.new(
      %{
        name: "Driver1",
        angles: [
          -45.0,
          -20.0,
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
          20.0,
          45.0
        ]
      }
    )
    [binary: binary, data: data]
  end

  test "From binary", context do

    parsed = InitData.from_binary(context[:binary])

    assert parsed.name == "Driver1"
    assert parsed.angles == [
             -45.0,
             -20.0,
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
             20.0,
             45.0
           ]
  end


  test "To binary", context do
    assert InitData.to_binary(InitData.new(context[:data])) == context[:binary]
  end


end
