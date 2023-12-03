defmodule Aoc2023.DayTwo do
  def parse_input(path) do
    Aoc2023.Utils.file_to_lines(path)
    |> Enum.map(&parse_game_info/1)
  end

  def part_one(path) do
    parse_input(path)
    |> Enum.filter(&valid_game?/1)
    |> Enum.map(fn game -> game.id end)
    |> Enum.sum()
  end

  def part_two(path) do
    parse_input(path)
    |> Enum.map(&calculate_power/1)
    |> Enum.sum()
  end

  def calculate_power(game) do
    Enum.group_by(game.selections, fn selection -> selection.color end)
    |> Enum.map(fn {_, selections} -> Enum.max_by(selections, fn item -> item.amount end) end)
    |> Enum.map(fn results -> results.amount end)
    |> Enum.reduce(fn x, acc -> x * acc end)
  end

  def parse_game_info(line) do
    [game_id_string, rest] = String.split(line, ":")
    [game_id] = Regex.run(~r/\d+/, game_id_string)

    games_string = String.split(rest, "; ")
    parsed_games = parse_game_string(games_string)

    %{id: String.to_integer(game_id), selections: parsed_games}
  end

  def valid_game?(game) do
    allowed = %{
      "red" => 12,
      "green" => 13,
      "blue" => 14
    }

    Enum.all?(
      game.selections,
      fn selection -> selection.amount <= Map.get(allowed, selection.color) end
    )
  end

  def parse_game_string(game_str) do
    game_str
    |> Enum.flat_map(fn game -> String.split(game, ", ") end)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_selection/1)
  end

  def parse_selection(input) do
    [amount, color] = String.split(input, " ")
    %{amount: String.to_integer(amount), color: color}
  end
end
