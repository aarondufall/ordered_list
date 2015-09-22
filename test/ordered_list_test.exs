defmodule OrderedListTest do
  use ExUnit.Case

  #insert_at/3

  test "#insert_at/3" do
    start_list = [
      %{id: 1, position: 1}, 
      %{id: 2, position: 2}, 
      %{id: 3, position: 3}, 
      %{id: 4, position: 4},
      %{id: 5, position: 5}
    ]

    # Move middle elements
    assert OrderedList.insert_at(start_list,%{id: 4, position: 4}, 2) == 
      [
        %{id: 1, position: 1}, 
        %{id: 4, position: 2},
        %{id: 2, position: 3}, 
        %{id: 3, position: 4}, 
        %{id: 5, position: 5}
      ]
    # Bottom to top
    assert OrderedList.insert_at(start_list,%{id: 5, position: 5}, 1) == 
      [
        %{id: 5, position: 1},
        %{id: 1, position: 2}, 
        %{id: 2, position: 3}, 
        %{id: 3, position: 4}, 
        %{id: 4, position: 5}
      ]

    # Top to bottom
    assert OrderedList.insert_at(start_list,%{id: 1, position: 1}, 5) == 
      [
        %{id: 2, position: 1}, 
        %{id: 3, position: 2}, 
        %{id: 4, position: 3},
        %{id: 5, position: 4},
        %{id: 1, position: 5} 
      ]
  end
end
