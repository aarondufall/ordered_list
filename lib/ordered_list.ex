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

  # defp move_down(list_item) do
  #   Map.put(list_item, :position, list_item.position + 1)
  # end

  # defp move_up(list_item) do
  #   Map.put(list_item, :position, list_item.position - 1)
  # end

end
