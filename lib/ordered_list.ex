defmodule OrderedList do

  def insert_at(list, element, new_position) do
    case valid_new_position?(list,element,new_position) do
      true ->  reorder_list(list, element, new_position)
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
