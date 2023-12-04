defmodule Aoc2023.DayFour do
  def part_one(path) do
    Aoc2023.Utils.file_to_lines(path)
    |> Enum.map(&parse_card_row/1)
    |> Enum.map(&card_score/1)
    |> Enum.sum()
  end

  def part_two(path) do
    all_cards =
      Aoc2023.Utils.file_to_lines(path)
      |> Enum.map(&parse_card_row/1)

    {_, updated} =
      Enum.reduce(all_cards, {0, all_cards}, fn _card, {index, cards_to_update} ->
        current_card = Enum.at(cards_to_update, index)
        updated_cards = update_multipliers(current_card, cards_to_update)
        {index + 1, updated_cards}
      end)

    Enum.reduce(updated, 0, fn card, acc -> acc + card.multiplier end)
  end

  def update_multipliers(card, all_cards) do
    winners = Enum.count(MapSet.intersection(card.winning_numbers, card.numbers))

    updated =
      Enum.slice(all_cards, card.index, winners)
      |> Enum.map(fn current_card ->
        Map.update!(current_card, :multiplier, fn v -> v + card.multiplier end)
      end)

    Enum.concat([
      Enum.slice(all_cards, 0..(card.index - 1)),
      updated,
      Enum.slice(all_cards, (card.index + winners)..Enum.count(all_cards))
    ])
  end

  def card_score(card) do
    MapSet.intersection(card.winning_numbers, card.numbers)
    |> Enum.reduce(0, fn _, acc ->
      case acc do
        0 -> 1
        x -> x * 2
      end
    end)
  end

  def parse_card_row(line) do
    [title, rest] = String.split(line, ": ")
    [_, id] = Regex.split(~r/\s+/, title)
    [winners, numbers] = String.split(rest, "|")

    %{
      index: String.to_integer(id),
      winning_numbers: MapSet.new(create_number_list(winners)),
      numbers: MapSet.new(create_number_list(numbers)),
      multiplier: 1
    }
  end

  def create_number_list(line) do
    Regex.split(~r/\s+/, String.trim(line))
    |> Enum.map(&String.to_integer/1)
  end
end
