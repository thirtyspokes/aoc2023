defmodule Aoc2023.Utils do
  def file_to_lines(path) do
    File.stream!(path)
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.to_list()
  end
end
