defmodule Scrc.HelperTest do
  @moduledoc false

  use ExUnit.Case

  test "123", do: assert Scrc.Helper.parse_number("123") == {123, ""}
  test "+123", do: assert Scrc.Helper.parse_number("+123") == {123, ""}
  test "-123", do: assert Scrc.Helper.parse_number("-123") == {-123, ""}

  test "0.123", do: assert Scrc.Helper.parse_number("0.123") == {0.123, ""}
  test "+0.123", do: assert Scrc.Helper.parse_number("+0.123") == {0.123, ""}
  test "-0.123", do: assert Scrc.Helper.parse_number("-0.123") == {-0.123, ""}

  test ".123", do: assert Scrc.Helper.parse_number(".123") == {0.123, ""}
  test "+.123", do: assert Scrc.Helper.parse_number("+.123") == {0.123, ""}
  test "-.123", do: assert Scrc.Helper.parse_number("-.123") == {-0.123, ""}

  test "123.456", do: assert Scrc.Helper.parse_number("123.456") == {123.456, ""}
  test "+123.456", do: assert Scrc.Helper.parse_number("+123.456") == {123.456, ""}
  test "-123.456", do: assert Scrc.Helper.parse_number("-123.456") == {-123.456, ""}

  test "123.0456", do: assert Scrc.Helper.parse_number("123.0456") == {123.0456, ""}
  test "+123.0456", do: assert Scrc.Helper.parse_number("+123.0456") == {123.0456, ""}
  test "-123.0456", do: assert Scrc.Helper.parse_number("-123.0456") == {-123.0456, ""}







end