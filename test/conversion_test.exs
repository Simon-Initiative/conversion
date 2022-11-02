defmodule ConversionTest do
  use ExUnit.Case
  doctest Conversion

  test "greets the world" do
    assert Conversion.hello() == :world
  end
end
