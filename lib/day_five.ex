defmodule Aoc2023.DayFive do
  def part_one(path) do
    parsed = parse_file(path)
    seeds = parsed.seeds
    maps = parsed.maps

    Enum.map(seeds, fn seed -> calculate_final_value(maps, seed) end)
    |> Enum.min()
  end

  def part_two(path) do
    parsed = parse_file(path)
    maps = parsed.maps
    ranges = expand_seeds_value(parsed.seeds)

    Enum.reduce_while(0..1_000_000_000_000, maps, fn loc, m ->
      seed = calculate_seed_value(m, loc)

      case is_in_initial_values(ranges, seed) do
        true -> {:halt, loc}
        false -> {:cont, m}
      end
    end)
  end

  def is_in_initial_values(seed_ranges, value) do
    Enum.any?(seed_ranges, fn range -> value in range end)
  end

  def calculate_final_value(maps, seed) do
    Enum.reduce(maps, seed, fn m, s ->
      next_position(s, m)
    end)
  end

  def calculate_seed_value(maps, seed) do
    maps = Enum.reverse(maps)

    Enum.reduce(maps, seed, fn m, s ->
      previous_position(s, m)
    end)
  end

  def expand_seeds_value(seeds) do
    Enum.chunk_every(seeds, 2)
    |> Enum.map(fn [start, len] -> start..(start + len - 1) end)
  end

  def next_position(destination_value, map) do
    case Enum.filter(map.ranges, fn %{source: [start, stop]} ->
           destination_value >= start && destination_value <= stop
         end) do
      [] ->
        destination_value

      [match] ->
        [sstart, _] = match.source
        [dstart, _] = match.destination
        dstart + (destination_value - sstart)
    end
  end

  def previous_position(source_value, map) do
    case Enum.filter(map.ranges, fn %{destination: [start, stop]} ->
           source_value >= start && source_value <= stop
         end) do
      [] ->
        source_value

      [match] ->
        [sstart, _] = match.destination
        [dstart, _] = match.source
        dstart + (source_value - sstart)
    end
  end

  def parse_file(path) do
    parsed =
      File.read!(path)
      |> String.split("\n\n")
      |> Enum.map(&String.split(&1, "\n"))

    [[seeds] | maps] = parsed

    parsed_seeds =
      seeds
      |> String.split(" ")
      |> tl
      |> Enum.map(&String.to_integer/1)

    parsed_maps =
      maps
      |> Enum.map(fn row ->
        ranges =
          Enum.map(tl(row), fn nums ->
            String.split(nums, " ") |> Enum.map(&String.to_integer/1)
          end)
          |> Enum.map(fn [dest_start, source_start, len] ->
            %{
              destination: [dest_start, dest_start + len - 1],
              source: [source_start, source_start + len - 1]
            }
          end)

        %{type: hd(row), ranges: ranges}
      end)

    %{seeds: parsed_seeds, maps: parsed_maps}
  end
end
