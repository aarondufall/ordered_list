defmodule OrderedList do
  @moduledoc ~S"""
  Provides a set of algorithms for sorting and reordering the position number of maps in a list.
  All of the functions expect a `List` where each element is a `Map` with a `:postion` key.

      iex> original_list = [%{id: 1, position: 1},%{id: 2, position: 2}, %{id: 3, position: 3},%{id: 4, position: 4},%{id: 5, position: 5}] 
      iex> OrderedList.insert_at(original_list,%{id: 4, position: 4}, 2)
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

  The return value is a `Tuple` where the first element is a list of maps that haven't had 
  their position changed. The second element is a `List` of tuples where the first element is 
  the original `Map` and the second is params for the new position. The idea being that you would 
  be able to pass each `Map` in the second list to create changesets with `Ecto`.


      post = MyRepo.get!(Post, 42)
      posts = MyRepo.all(Post)
      { same_positions, new_positions } = OrderedList.insert_at(posts, post, 3)

      Repo.transaction fn ->
        Enum.each new_positions, fn (post) ->
          case MyRepo.update post do
            {:ok, model}        -> # Updated with success
            {:error, changeset} -> # Something went wrong
          end
        end
      end
  """

  @doc ~S"""
  Retuns a `Tuple` of two elements, the first being a `List` of maps that don't need there position updated.
  The second is a `List` of tuples with the first element being the original `Map` and second being a `Map` 
  with new `:position`. 

    * `list` - A `List` where each element is a `Map` or `Struct` that contains a `:position` key.

    * `original_element` - A `Map` or `Struct` that is contained within the `list` in the first argument

    * `new_position` - An `Integer` of position that the `original_element` is moving to.


      iex> original_list = [%{id: 1, position: 1},%{id: 2, position: 2}, %{id: 3, position: 3},%{id: 4, position: 4},%{id: 5, position: 5}] 
      iex> OrderedList.insert_at(original_list,%{id: 4, position: 4}, 2)
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

  """

  def insert_at(list, original_element, new_position) do
    case valid_new_position?(list,original_element,new_position) do
      true ->  reorder_list(list, original_element, new_position)
      false -> { list, [] }  
    end    
  end

  @doc ~S"""
  Moves the element one position down the list. Lower down the list means that the position
  number will be higher.

    * `list` - A `List` where each element is a `Map` or `Struct` that contains a `:position` key. 

    * `original_element` - A `Map` or `Struct` that is contained within the `list` in the first argument 


      iex> original_list = [%{id: 1, position: 1},%{id: 2, position: 2}, %{id: 3, position: 3},%{id: 4, position: 4},%{id: 5, position: 5}]
      iex> OrderedList.move_lower(original_list, %{id: 1, position: 1})
      {
        #Unchanged
        [%{id: 3, position: 3}, %{id: 4, position: 4}, %{id: 5, position: 5}],
        #Changed 
        [
          {%{id: 1, position: 1}, %{position: 2}}, 
          {%{id: 2, position: 2}, %{position: 1}}
        ]
      }

  The position number will remain unchanged if it is already in the lowest position.

  """

  def move_lower(list, original_element) do
    insert_at(list,original_element, original_element.position + 1)
  end

  @doc ~S"""
  Moves the `original_element` one position up the list. Higher up the list means that the position
  number will be lower.

    * `list` - A `List` where each element is a `Map` or `Struct` that contains a `:position` key. 

    * `original_element` - A `Map` or `Struct` that is contained within the `list` in the first argument 


      iex> original_list = [%{id: 1, position: 1},%{id: 2, position: 2}, %{id: 3, position: 3},%{id: 4, position: 4},%{id: 5, position: 5}]
      iex> OrderedList.move_higher(original_list, %{id: 5, position: 5})
      {
        #Unchanged
        [%{id: 1, position: 1}, %{id: 2, position: 2}, %{id: 3, position: 3}], 
        #Changed
        [{%{id: 4, position: 4}, %{position: 5}}, {%{id: 5, position: 5}, %{position: 4}}]
      }

  The position number will remain unchanged if it is already in the highest position.

  """
  def move_higher(list, original_element) do
    insert_at(list,original_element, original_element.position - 1)
  end

  @doc ~S"""
  Moves the `original_element` to the bottom of the list.
  
    * `list` - A `List` where each element is a `Map` or `Struct` that contains a `:position` key. 

    * `original_element` - A `Map` or `Struct` that is contained within the `list` in the first argument 

      
      iex> original_list = [%{id: 1, position: 1},%{id: 2, position: 2}, %{id: 3, position: 3},%{id: 4, position: 4},%{id: 5, position: 5}]
      iex> OrderedList.move_to_bottom(original_list, %{id: 1, position: 1})
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

    The position number will remain unchanged if it is already in the lowest position.
  """

  def move_to_bottom(list, original_element) do
    max = Enum.max_by(list, &(&1.position))
    insert_at(list, original_element, max.position)
  end

  @doc ~S"""
  Moves the `original_element` to the top of the list.
  
    * `list` - A `List` where each element is a `Map` or `Struct` that contains a `:position` key. 

    * `original_element` - A `Map` or `Struct` that is contained within the `list` in the first argument 

      
      iex> original_list = [%{id: 1, position: 1},%{id: 2, position: 2}, %{id: 3, position: 3},%{id: 4, position: 4},%{id: 5, position: 5}]
      iex> OrderedList.move_to_top(original_list, %{id: 5, position: 5})
      {
        #Unchanged
        [],
        #Changed    
        [
          {%{id: 1, position: 1}, %{position: 2}}, 
          {%{id: 2, position: 2}, %{position: 3}}, 
          {%{id: 3, position: 3}, %{position: 4}}, 
          {%{id: 4, position: 4}, %{position: 5}},
          {%{id: 5, position: 5}, %{position: 1}}
        ]
      }

    The position number will remain unchanged if it is already in the highest position.
  """

  def move_to_top(list, original_element) do
    min = Enum.min_by(list, &(&1.position))
    insert_at(list, original_element, min.position)
  end

  @doc ~S"""
  
  Returns a `Tuple` that contain two elements, the first being the item to be 
  removed and the second a `Tuple` containing the changes to positions that 
  have been effected by the removal of the element.

    * `list` - A `List` where each element is a `Map` or `Struct` that contains a `:position` key. 

    * `original_element` - A `Map` or `Struct` that is contained within the `list` in the first argument 

      
      iex> original_list = [%{id: 1, position: 1},%{id: 2, position: 2}, %{id: 3, position: 3},%{id: 4, position: 4},%{id: 5, position: 5}]
      iex> OrderedList.remove_from_list(original_list, %{id: 3, position: 3})
      {
        #Remove
        %{id: 3, position: 3},
        {
          #Unchanged
          [%{id: 1, position: 1}, %{id: 2, position: 2}],
          #Changed    
          [   
            {%{id: 4, position: 4}, %{position: 3}},
            {%{id: 5, position: 5}, %{position: 4}}
          ]
        }
      }

  """

  def remove_from_list(list, original_element) do
    { delete, keep } = Enum.partition(list, &(&1.position == original_element.position))
    { reorder, keep} = Enum.partition(keep, &(&1.position > original_element.position))

    reorder = decrement_positions(reorder)

    { List.first(delete), {keep,reorder} }
  end

  @doc ~S"""
  Returns a `boolean` value if the element is in the first `:position` in the list.

    * `list` - A `List` where each element is a `Map` or `Struct` that contains a `:position` key. 

    * `original_element` - A `Map` or `Struct` that is contained within the `list` in the first argument 

      
      iex> original_list = [%{id: 1, position: 1},%{id: 2, position: 2}, %{id: 3, position: 3},%{id: 4, position: 4},%{id: 5, position: 5}]
      iex> OrderedList.first?(original_list, %{id: 1, position: 1})
      true
      iex> OrderedList.first?(original_list, %{id: 2, position: 2})
      false

  """  
  def first?(_list, original_element) do
    original_element.position == 1
  end


  @doc ~S"""
  Returns a `boolean` value if the element is in the last `:position` in the list.

    * `list` - A `List` where each element is a `Map` or `Struct` that contains a `:position` key. 

    * `original_element` - A `Map` or `Struct` that is contained within the `list` in the first argument 

      
      iex> original_list = [%{id: 1, position: 1},%{id: 2, position: 2}, %{id: 3, position: 3},%{id: 4, position: 4},%{id: 5, position: 5}]
      iex> OrderedList.last?(original_list, %{id: 5, position: 5})
      true
      iex> OrderedList.last?(original_list, %{id: 4, position: 4})
      false

  """ 
  def last?(list, original_element) do
    Enum.max_by(list, &(&1.position)).position == original_element.position
  end

  #private

  defp reorder_list(list,element,new_position) do
    { reorder, ordered } = Enum.partition(list, &(&1.position in element.position..new_position))
    reorder = Enum.filter(reorder, &(&1.position != element.position))

    reorder = 
      case element.position > new_position do 
        true -> increment_positions(reorder)
        false -> decrement_positions(reorder)
      end

    element = { element, %{ position: new_position } }
    
    {ordered, Enum.sort_by(reorder ++ [element], &(elem(&1, 0).position))}
  end

  defp valid_new_position?(list, element, new_position) do
    element.position != new_position && 
    !(first?(list, element) && new_position < 1) &&
    !(last?(list, element) && new_position > element.position)
  end

  defp increment_positions(list) do
    Enum.map(list, fn(list_item) -> { list_item, %{ position: list_item.position + 1 } } end)
  end

  defp decrement_positions(list) do
    Enum.map(list, fn(list_item) -> { list_item, %{ position: list_item.position - 1 } } end)
  end

end
