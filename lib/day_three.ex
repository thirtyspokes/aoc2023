defmodule Aoc2023.DayThree do
  def part_one(path) do
    all_lines = Aoc2023.Utils.file_to_lines(path)

    Enum.with_index(all_lines)
    |> Enum.flat_map(fn {line, index} -> number_matches(all_lines, line, index) end)
    |> Enum.filter(&is_integer/1)
    |> Enum.sum()
  end

  def part_two(path) do
    all_lines = Aoc2023.Utils.file_to_lines(path)

    Enum.with_index(all_lines)
    |> Enum.map(fn {_, idx} -> gear_matches(idx, all_lines) end)
    |> Enum.reject(&is_nil/1)
    |> Enum.flat_map(fn idx -> find_gears(idx, all_lines) end)
    |> Enum.reject(fn x -> Enum.count(x) != 2 end)
    |> Enum.map(fn [x, y] -> x * y end)
    |> Enum.sum()
  end

  def gear_matches(line_index, all_lines) do
    line = Enum.at(all_lines, line_index)

    if Regex.match?(~r/\*/, line) do
      line_index
    else
      nil
    end
  end

  def adjacent_to_gear(number_match, gear) do
    %{index: y, start: xstart, stop: xstop} = number_match
    valid_range = (xstart - 1)..(xstop + 1)

    if y in (gear.index - 1)..(gear.index + 1) do
      gear.start in valid_range
    else
      false
    end
  end

  def find_gears(line_index, all_lines) do
    line = Enum.at(all_lines, line_index)
    gear_positions = Regex.scan(~r/\*/, line, return: :index)

    gears =
      Enum.with_index(gear_positions)
      |> Enum.map(fn {[{start, _}], id} -> %{id: id, index: 1, start: start} end)

    numbers =
      create_line_group(all_lines, line, line_index)
      |> Enum.reject(&is_nil/1)
      |> Enum.with_index()
      |> Enum.flat_map(fn {line_to_check, index} ->
        parse_match_result(
          Regex.scan(~r/\d+/, line_to_check, return: :index),
          line_to_check,
          index
        )
      end)

    Enum.map(gears, fn gear ->
      Enum.map(numbers, fn number ->
        if adjacent_to_gear(number, gear) do
          number.number
        else
          nil
        end
      end)
      |> Enum.reject(&is_nil/1)
    end)
  end

  def number_matches(all_lines, current_line, current_index) do
    line_group = create_line_group(all_lines, current_line, current_index)
    line_to_check = current_line

    parsed_matches =
      parse_match_result(Regex.scan(~r/\d+/, line_to_check, return: :index), line_to_check)

    find_part_number(line_group, parsed_matches)
  end

  def find_part_number(line_group, parsed_matches) do
    Enum.flat_map(line_group, fn line ->
      symbol_matches = Regex.scan(~r/[!=\+\-\@\#\$\%\^\&\*\/]/, line, return: :index)

      Enum.flat_map(symbol_matches, fn [{pos, _len}] ->
        Enum.map(parsed_matches, fn %{start: start, stop: stop, number: number} ->
          if pos in (start - 1)..(stop + 1) do
            number
          end
        end)
      end)
    end)
  end

  def parse_match_result([], _line), do: []

  def parse_match_result(matches, line, index \\ 0) do
    Enum.map(matches, fn [{start, length}] ->
      capture = String.slice(line, start, length)
      %{index: index, number: String.to_integer(capture), start: start, stop: start + length - 1}
    end)
  end

  def create_line_group(all_lines, current_line, current_index) do
    first =
      if current_index == 0 do
        nil
      else
        Enum.at(all_lines, current_index - 1)
      end

    last =
      if current_index == Enum.count(all_lines) - 1 do
        nil
      else
        Enum.at(all_lines, current_index + 1)
      end

    Enum.reject(
      [
        first,
        current_line,
        last
      ],
      &is_nil/1
    )
  end
end
