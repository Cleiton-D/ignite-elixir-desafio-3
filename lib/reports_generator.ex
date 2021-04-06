defmodule ReportsGenerator do
  alias ReportsGenerator.Parser

  @months %{
    1 => "janeiro",
    2 => "fevereiro",
    3 => "março",
    4 => "abril",
    5 => "maio",
    6 => "junho",
    7 => "julho",
    8 => "agosto",
    9 => "setembro",
    10 => "outubro",
    11 => "novembro",
    12 => "dezembro"
  }

  def build(filename) do
    lines = Parser.parse_file(filename)

    lines
    |> Enum.reduce(build_acc(lines), fn line, acc ->
      sum_values(line, acc)
    end)
  end

  defp sum_values([name, hours, _day, month, year], acc) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    } = acc

    per_year = hours_per_year[name]
    per_month = hours_per_month[name]
    month_name = @months[month]

    all_hours = Map.put(all_hours, name, all_hours[name] + hours)

    per_month = Map.put(per_month, month_name, per_month[month_name] + hours)
    hours_per_month = Map.put(hours_per_month, name, per_month)

    per_year = Map.put(per_year, year, per_year[year] + hours)
    hours_per_year = Map.put(hours_per_year, name, per_year)

    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end

  defp build_acc(lines) do
    initial_acc = %{
      "all_hours" => %{},
      "hours_per_month" => %{},
      "hours_per_year" => %{}
    }

    lines
    |> Enum.map(fn [name, _hours, _day, _month, _year] -> name end)
    |> Enum.uniq()
    |> Enum.reduce(initial_acc, fn name, acc ->
      build_map(name, acc)
    end)
  end

  defp build_map(name, acc) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    } = acc

    per_month = Enum.into(Map.values(@months), %{}, &{&1, 0})
    per_year = Enum.into(2016..2020, %{}, &{Integer.to_string(&1), 0})

    all_hours = Map.put(all_hours, name, 0)
    hours_per_month = Map.put(hours_per_month, name, per_month)
    hours_per_year = Map.put(hours_per_year, name, per_year)

    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end
