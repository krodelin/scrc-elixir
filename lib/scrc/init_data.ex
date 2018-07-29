defmodule Scrc.InitData do
  @moduledoc """
  InitData provides the struct for SCRC init data.
  """

  @type t :: %Scrc.InitData{name: String.t, angles: [float]}

  use Scrc.Mapper

  defstruct name: "SCR",
            angles: [
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

  prefix :name, :string
  field "init", :angles, [:float]


end

