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
    the orginal `Map` and the second is params for the new position. The idea being that you would 
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
    The second is a `List` of tuples with the first element being the orginal `Map` and second being a `Map` 
    with new `:position`. 

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

  def insert_at(list, orginal_element, new_position) do
    case valid_new_position?(list,orginal_element,new_position) do
      true ->  reorder_list(list, orginal_element, new_position)
      false -> { list, [] }  
    end    
  end

  def move_lower(list, element) do
    insert_at(list,element, element.position + 1)
  end

  def move_higher(list, element) do
    insert_at(list,element, element.position - 1)
  end

  def move_to_bottom(list, element) do
    max = Enum.max_by(list, &(&1.position))
    insert_at(list, element, max.position)
  end

  def move_to_top(list, element) do
    min = Enum.min_by(list, &(&1.position))
    insert_at(list, element, min.position)
  end


  def remove_from_list(list, element) do
    { delete, keep } = Enum.partition(list, &(&1.position == element.position))
    { reorder, keep} = Enum.partition(keep, &(&1.position > element.position))

    reorder = decrement_positions(reorder)

    { List.first(delete), {keep,reorder} }
  end

  def first?(_, element) do
    element.position == 1
  end

  def last?(list, element) do
    Enum.max_by(list, &(&1.position)).position == element.position
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
