defmodule MeatheadsWeightCalculator do
  @weeks_and_percentages %{
    "1"       => [0.65, 0.75, 0.85],
    "2"       => [0.7, 0.8, 0.9],
    "3"       => [0.75, 0.85, 0.95],
    "deload"  => [0.7, 0.8, 0.9, 1]
  }
  @lift_names ~w(squat sq deadlift dl bench b press pr)a

  def main(args) do
    args |> parse_args |> print_weights
  end

  def print_weights(options) when options == %{} do
    IO.puts """
      ./meatheads_weight_calculator --LIFT_NAME WEIGHT_IN_KG [--LIFT_NAME WEIGHT_IN_KG ...] --WEEK WEEK_NUM

      Examples:
      ./meatheads_weight_calculator --squat 150 --deadlift 172.5 --week 3
      =>  Weights for week 3:
          deadlift: 130.0, 145.0, 162.5
          squat: 112.5, 127.5, 142.5

      ./meatheads_weight_calculator --press 80 --week deload
      =>  Weights for week deload:
          press: 55.0, 65.0, 72.5, 80.0

      Supported lifts in the default settings are squat (sq), deadlift (dl), press (pr) and bench (b).
    """
  end

  def print_weights(options = %{week: week_num}) do
    @weeks_and_percentages
    |> Map.get(week_num, [0])
    |> calculate_this_weeks_weights(options)
  end

  def print_weights(_) do
    IO.puts "No week number given! Usage:"
    print_weights(%{})
  end

  defp calculate_this_weeks_weights(weight_percentages, options) do
    IO.puts "Weights for week #{options[:week]}:"
    for {lift_name, training_max} <- options,
        Enum.member?(@lift_names, lift_name) do
      IO.puts """
        #{lift_name}:
          warm-up sets: #{calculate_warmup_sets(training_max)},
          work sets:    #{calculate_weight_to_nearest_2_point_5_kg(weight_percentages, training_max)}
      """
    end
  end

  defp calculate_weight_to_nearest_2_point_5_kg(weight_percentages, training_max) do
    training_max_int = Float.floor(training_max)
    for percentage <- weight_percentages do
      Float.round(training_max_int * percentage / 2.5) * 2.5 |> Float.to_string
    end
    |> Enum.join(", ")
  end

  defp calculate_warmup_sets(training_max) do
    calculate_weight_to_nearest_2_point_5_kg([0.4, 0.5, 0.6], training_max)
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [
        week:     :string,
        squat:    :float, sq: :float,
        deadlift: :float, dl: :float,
        press:    :float, pr: :float,
        bench:    :float, b:  :float
      ]
    )
    options |> Enum.into(%{})
  end
end
