defmodule Aoc2023.DaySix do
  def part_one_and_also_part_two(path) do
    Aoc2023.Utils.file_to_lines(path)
    |> Enum.map(&Regex.split(~r/\s+/, &1))
    |> Enum.map(&tl/1)
    |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))
    |> Enum.zip()
    |> Enum.map(fn {time, distance} ->
      Enum.filter(1..(time - 1), fn v -> hold_time_wins(v, time, distance) end)
    end)
    |> Enum.map(&Enum.count/1)
    |> Enum.reduce(&*/2)
  end

  def hold_time_wins(hold_time, time, distance) do
    remainder = time - hold_time
    remainder * hold_time > distance
  end
end
