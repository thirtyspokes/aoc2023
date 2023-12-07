defmodule Aoc2023.DaySeven do
  def part_one(path) do
    Aoc2023.Utils.file_to_lines(path)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn [hand, bid] ->
      %{
        hand: categorize_hand(hand),
        bid: String.to_integer(bid)
      }
    end)
    |> sort_by_strength()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {hand, index}, acc ->
      acc + (index + 1) * hand.bid
    end)
  end

  def part_two(path) do
    Aoc2023.Utils.file_to_lines(path)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn [hand, bid] ->
      %{
        hand: categorize_upgraded_hand(hand),
        bid: String.to_integer(bid)
      }
    end)
    |> sort_by_strength()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {hand, index}, acc ->
      acc + (index + 1) * hand.bid
    end)
  end

  def sort_by_strength(cards) do
    cards
    |> Enum.sort_by(
      & &1,
      fn hand1, hand2 ->
        if hand1.hand.hand_strength == hand2.hand.hand_strength do
          Enum.zip(hand1.hand.card_strengths, hand2.hand.card_strengths)
          |> Enum.reduce_while([], fn {card1, card2}, _acc ->
            if card1 == card2 do
              {:cont, true}
            else
              {:halt, card1 < card2}
            end
          end)
        else
          hand1.hand.hand_strength < hand2.hand.hand_strength
        end
      end
    )
  end

  def categorize_upgraded_hand(original_cards) do
    cards = String.split(original_cards, "", trim: true)
    upgraded_card_string = upgrade_jokers(original_cards)
    upgraded_cards = String.split(upgraded_card_string, "", trim: true)

    freqs =
      Enum.frequencies(upgraded_cards)

    hand_type = hand_type(freqs)

    %{
      cards: cards,
      hand: hand_type(freqs),
      hand_strength: hand_strength(hand_type),
      card_strengths: Enum.map(cards, &card_strength(&1, true))
    }
  end

  def categorize_hand(cards) do
    cards = String.split(cards, "", trim: true)

    freqs =
      Enum.frequencies(cards)

    hand_type = hand_type(freqs)

    %{
      cards: cards,
      hand: hand_type(freqs),
      hand_strength: hand_strength(hand_type),
      card_strengths: Enum.map(cards, &card_strength/1)
    }
  end

  def hand_strength(type) do
    case type do
      :five_of_a_kind -> 6
      :four_of_a_kind -> 5
      :full_house -> 4
      :three_of_a_kind -> 3
      :two_pair -> 2
      :one_pair -> 1
      _ -> 0
    end
  end

  def card_strength(card, wildcards \\ false) do
    all_cards = %{
      "A" => 13,
      "K" => 12,
      "Q" => 11,
      "J" =>
        if wildcards do
          0
        else
          10
        end,
      "T" => 9,
      "9" => 8,
      "8" => 7,
      "7" => 6,
      "6" => 5,
      "5" => 4,
      "4" => 3,
      "3" => 2,
      "2" => 1
    }

    Map.get(all_cards, card)
  end

  def hand_type(frequencies_map) do
    case Enum.sort(Map.values(frequencies_map)) do
      [5] -> :five_of_a_kind
      [1, 4] -> :four_of_a_kind
      [2, 3] -> :full_house
      [1, 1, 3] -> :three_of_a_kind
      [1, 2, 2] -> :two_pair
      [1, 1, 1, 2] -> :one_pair
      _ -> :high_card
    end
  end

  def upgrade_jokers(card_str) do
    case card_str do
      "JJJJJ" ->
        "AAAAA"

      _ ->
        cards = String.split(card_str, "", trim: true)
        frequencies = Map.delete(Enum.frequencies(cards), "J")
        {best, _} = Enum.max_by(frequencies, fn {_k, v} -> v end)
        String.replace(card_str, "J", best, global: true)
    end
  end
end
