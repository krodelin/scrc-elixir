defmodule Scrc.DataClipper do

  def clip(%_{} = payload, payload_fields) do

    clipped_fields = payload_fields
                     |> Enum.map(fn field -> clip_payload_field(payload, field) end)
                     |> Enum.into(%{})

    Map.merge(payload, clipped_fields)


  end

  defp do_clip(value, list) when is_list(list) do
    if value in list, do: value, else: nil
  end

  defp do_clip(value, range) when is_tuple(range) do
    {min, max} = range
    min(max, max(min, value))
  end

  defp clip_payload_field(%_{} = payload, field) do
    {_name, key, _type, opts} = field
    value = clip_opts(Map.get(payload, key), opts)
    {key, value}
  end

  defp clip_opts(value, []) do
    value
  end

  defp clip_opts(value, [{:clip, range_or_list} | t]) do
    value
    |> do_clip(range_or_list)
    |> clip_opts(t)
  end

  defp clip_opts(value, [{:default, default} | t]) do
    (if value == nil, do: default,
                      else: value)
    |> clip_opts(t)
  end

  defp clip_opts(_value, [{key, _} | _t]) do
    raise(ArgumentError, "unknown option key '#{key}'")
  end

end