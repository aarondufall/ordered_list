defmodule OrderedList do

  def insert_at(list, element, new_position) do
    list
      |> Enum.filter(&(&1 != element))
      |> Enum.sort_by(&(&1.position))
      |> Enum.partition(&(&1.position < new_position))
      |> reposition(element,new_position)      
  end

  #private

  defp reposition({before, [rest]}, element, new_position) do
    decrement_positions(before ++ [rest], element.position)
    ++ [Map.put(element, :position, new_position)] 
  end

  defp reposition({before, rest}, element, new_position) do
    before
    ++ [Map.put(element, :position, new_position)] 
    ++ increment_positions(rest, element.position)
  end

  defp increment_positions(list, stop) do
    {increment, leave} = Enum.partition(list, &(&1.position < stop))
    Enum.map(increment, fn(list_item) -> move_down(list_item) end) ++ leave
  end

  defp decrement_positions(list, stop) do
    {decrement, _ } = Enum.partition(list, &(&1.position > stop))
    Enum.map(list, fn(list_item) -> move_up(list_item) end)
  end

  defp move_down(list_item) do
    Map.put(list_item, :position, list_item.position + 1)
  end

  defp move_up(list_item) do
    Map.put(list_item, :position, list_item.position - 1)
  end

end
