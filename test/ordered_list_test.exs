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
      {  
        #Unchanged
        [%{id: 1, position: 1}, %{id: 5, position: 5}],
        #Changed
        [
          {%{id: 2, position: 2}, %{ position: 3 }}, 
          {%{id: 3, position: 3}, %{ position: 4 }}, 
          {%{id: 4, position: 4}, %{ position: 2 }}
        ]
      }

    # Bottom to top
    assert OrderedList.insert_at(start_list,%{id: 5, position: 5}, 1) == 
      {
        #Unchanged
        [],
        #Changed
        [
          {%{id: 1, position: 1}, %{ position: 2 }}, 
          {%{id: 2, position: 2}, %{ position: 3 }}, 
          {%{id: 3, position: 3}, %{ position: 4 }},
          {%{id: 4, position: 4}, %{ position: 5 }}, 
          {%{id: 5, position: 5}, %{ position: 1 }}
        ]
      }

    # Top to bottom
    assert OrderedList.insert_at(start_list,%{id: 1, position: 1}, 5) == 
      {
        #Unchanged
        [],
        #Changed    
        [
          {%{id: 1, position: 1}, %{position: 5}}, 
          {%{id: 2, position: 2}, %{position: 1}}, 
          {%{id: 3, position: 3}, %{position: 2}}, 
          {%{id: 4, position: 4}, %{position: 3}},
          {%{id: 5, position: 5}, %{position: 4}}
        ]
      }
  end

  # #move_lower/2

  test "#move_lower/2" do 
    start_list = [
      %{id: 1, position: 1}, 
      %{id: 2, position: 2}, 
      %{id: 3, position: 3}, 
      %{id: 4, position: 4},
      %{id: 5, position: 5}
    ]

    # Top
    assert OrderedList.move_lower(start_list, %{id: 1, position: 1}) ==
      {
        #Unchanged
        [%{id: 3, position: 3}, %{id: 4, position: 4}, %{id: 5, position: 5}],
        #Changed 
        [
          {%{id: 1, position: 1}, %{position: 2}}, 
          {%{id: 2, position: 2}, %{position: 1}}
        ]
      }

    # Middle
    assert OrderedList.move_lower(start_list, %{id: 3, position: 3}) ==
      {
        #Unchanged
        [%{id: 1, position: 1}, %{id: 2, position: 2}, %{id: 5, position: 5}], 
        #Changed
        [{%{id: 3, position: 3}, %{position: 4}}, {%{id: 4, position: 4}, %{position: 3}}]
      }

    # Bottom
    assert OrderedList.move_lower(start_list, %{id: 5, position: 5}) ==
      {
        #Unchanged
        [
          %{id: 1, position: 1}, 
          %{id: 2, position: 2}, 
          %{id: 3, position: 3}, 
          %{id: 4, position: 4}, 
          %{id: 5, position: 5}
        ],
        #Change 
        []
      }

  end

  #move_higher/2
  
  test "#move_higher/2" do 
    start_list = [
      %{id: 1, position: 1}, 
      %{id: 2, position: 2}, 
      %{id: 3, position: 3}, 
      %{id: 4, position: 4},
      %{id: 5, position: 5}
    ]

    # Top
    assert OrderedList.move_higher(start_list, %{id: 1, position: 1}) ==
      {
        #Unchanged
        [
          %{id: 1, position: 1}, 
          %{id: 2, position: 2}, 
          %{id: 3, position: 3}, 
          %{id: 4, position: 4}, 
          %{id: 5, position: 5}
        ],
        #Change 
        []
      }
    # Middle
    assert OrderedList.move_higher(start_list, %{id: 3, position: 3}) ==
      { 
        #Unchanged
        [%{id: 1, position: 1}, %{id: 4, position: 4}, %{id: 5, position: 5}],
        #Changed 
        [{%{id: 2, position: 2}, %{position: 3}}, {%{id: 3, position: 3}, %{position: 2}}]
      }

    # Bottom
    assert OrderedList.move_higher(start_list, %{id: 5, position: 5}) ==
      {
        #Unchanged
        [%{id: 1, position: 1}, %{id: 2, position: 2}, %{id: 3, position: 3}], 
        #Changed
        [{%{id: 4, position: 4}, %{position: 5}}, {%{id: 5, position: 5}, %{position: 4}}]
      }

  end

  #first?/2

  test "first?/2" do
    start_list = [
      %{id: 1, position: 1}, 
      %{id: 2, position: 2}, 
      %{id: 3, position: 3}, 
      %{id: 4, position: 4},
      %{id: 5, position: 5}
    ]
    assert OrderedList.first?(start_list, %{id: 1, position: 1}) == true
    refute OrderedList.first?(start_list, %{id: 2, position: 2}) == true
    refute OrderedList.first?(start_list, %{id: 3, position: 3}) == true
    refute OrderedList.first?(start_list, %{id: 4, position: 4}) == true
    refute OrderedList.first?(start_list, %{id: 5, position: 5}) == true
  end

  #last?/2

  test "first?/2" do
    start_list = [
      %{id: 1, position: 1}, 
      %{id: 2, position: 2}, 
      %{id: 3, position: 3}, 
      %{id: 4, position: 4},
      %{id: 5, position: 5}
    ]
    refute OrderedList.last?(start_list, %{id: 1, position: 1}) == true
    refute OrderedList.last?(start_list, %{id: 2, position: 2}) == true
    refute OrderedList.last?(start_list, %{id: 3, position: 3}) == true
    refute OrderedList.last?(start_list, %{id: 4, position: 4}) == true
    assert OrderedList.last?(start_list, %{id: 5, position: 5}) == true
  end

end
