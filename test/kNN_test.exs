defmodule KNNTest do
  use ExUnit.Case
  require Logger
  doctest KNN
  
  defp record_set() do
    [ 
      %{"x" => 1.0, "y" => 5.0},
      %{"x" => 3.0, "y" => 7.0},
      %{"x" => 2.0, "y" => 10.0},
      %{"x" => 7.0, "y" => 200.0},
    ]
  end

  defp bounds_example() do {0.5, 1.5, 4.5, 5.5} end

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "Polling a record works correctly" do
    state = {record_set(), "x", "y"}
    expected = {:reply, [%{"x" => 1.0, "y" => 5.0}], state}
    assert(expected == KNN.Node.Store.handle_call({:get_for_cell, bounds_example() }, nil, state))
  end

  test "Adding a record works correctly" do

    # Test that appending a record works as expected
    new_record = %{"x" => 1.1, "y" => 4.7}
    state = {record_set(), "x", "y"}
    new_state = { [ new_record | record_set() ], "x", "y" }
    expected = {:reply, :ok, new_state}
    assert(expected == KNN.Node.Store.handle_call({:append, new_record}, nil, state))

    # Test that the search reflects the new record
    expected = {:reply, [new_record, %{"x" => 1.0, "y" => 5.0}], new_state}
    assert(expected == KNN.Node.Store.handle_call({:get_for_cell, bounds_example()}, nil, new_state))

  end

  test "Bounds work" do
    bound = KNN.Structs.Bounds.new(1.0, 2.0, 5.0, 6.0)

    assert (KNN.Structs.Bounds.point_in(bound, {1.5, 5.5}))
  end

end
