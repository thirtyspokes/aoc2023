defmodule Aoc2023.DayOne do
  def parse_input(path) do
    Aoc2023.Utils.file_to_lines(path)
  end

  def part_one(path) do
    parse_input(path)
    |> to_digits
    |> Enum.map(fn line -> Enum.map(line, &String.to_integer/1) end)
    |> Enum.map(&line_sum/1)
    |> Enum.sum()
  end

  def part_two(path) do
    parse_input(path)
    |> Enum.map(&replace_words/1)
    |> to_digits
    |> Enum.map(fn line -> Enum.map(line, &String.to_integer/1) end)
    |> Enum.map(&line_sum/1)
    |> Enum.sum()
  end

  def to_digits(list) do
    list
    |> Enum.map(fn line -> Regex.scan(~r/\d/, line) end)
    |> Enum.map(fn line -> List.flatten(line) end)
  end

  def line_sum(digits_line) do
    case Enum.count(digits_line) do
      1 -> String.to_integer("#{List.first(digits_line)}#{List.first(digits_line)}")
      _ -> String.to_integer("#{List.first(digits_line)}#{List.last(digits_line)}")
    end
  end

  def replace_words(line) do
    replacements = %{
      "one" => "o1e",
      "two" => "t2o",
      "three" => "t3e",
      "four" => "f4r",
      "five" => "f5e",
      "six" => "s6x",
      "seven" => "s7n",
      "eight" => "e8t",
      "nine" => "n9e"
    }

    Enum.reduce(
      Map.keys(replacements),
      line,
      fn val, str -> String.replace(str, val, Map.get(replacements, val)) end
    )
  end
end
