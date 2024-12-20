require 'csv'

data = CSV.read('./timeseries.csv', headers: true)

# takes a csv of date,kp; returns a map like:
# { start_value => { end_value => frequency } }
def csv_to_transition_counts(csv)
  csv.each.with_index.reduce(Hash.new { |hash, key| hash[key] = Hash.new(0) }) do |acc, (row, i)|
    curr = row['kp']
    prev = csv[i - 1]['kp']
    acc[prev][curr] += 1
    acc
  end
end

# takes a map of { start_value => { end_value => frequency } }
# and returns a map of { start_value => { end_value => probability } }
def transition_counts_to_probabilities(transition_counts)
  transition_counts.reduce(Hash.new { |hash, key| hash[key] = Hash.new(0.0) }) do |acc, (k, transitions)|
    total = transitions.values.sum
    acc[k] = transitions.transform_values { |v| v.to_f / total }
    acc
  end
end

def follow_markov_chain(transition_probabilities, start_value, steps)
  result = [start_value]
  current_value = start_value

  steps.times do
    next_value = sample_next_value(transition_probabilities[current_value])
    result << next_value
    current_value = next_value
  end

  result
end

def sample_next_value(transitions)
  cumulative_probabilities = []
  cumulative_sum = 0.0

  transitions.each do |value, probability|
    cumulative_sum += probability
    cumulative_probabilities << [cumulative_sum, value]
  end

  random_value = rand

  cumulative_probabilities.each do |cumulative_probability, value|
    return value if random_value <= cumulative_probability
  end
end

LAST_DATETIME = data[-1]['datetime']
LAST_VALUE = data[-1]['kp']
WINDOW_START = '2024-07-17T00:00Z'.freeze
STEPS_WITHIN_WINDOW = 11 * 8 # 11 days times 8 readings per day
NUM_SIMS = 100_000
STEPS_UNTIL_WINDOW = ((DateTime.parse(WINDOW_START) - DateTime.parse(LAST_DATETIME)) * 8).to_i

def fract(results, range)
  results.select { |result| range.cover?(result.to_f) }.size.to_f / NUM_SIMS
end

def run(data, timerange)
  probabilities = transition_counts_to_probabilities(csv_to_transition_counts(data.select { |row| timerange.cover?(row['datetime']) }))
  num_steps = STEPS_UNTIL_WINDOW + STEPS_WITHIN_WINDOW

  results = NUM_SIMS.times.map do
    follow_markov_chain(probabilities, LAST_VALUE, num_steps).last(STEPS_WITHIN_WINDOW)
  end.map(&:max)


  zeroto4 = fract(results, (0..4))
  between4and6 = fract(results, (4.01..6))
  between4and5 = fract(results, (4.01..5))
  between5and6 = fract(results, (5.01..6))
  over6 = fract(results, (6.01..))

  raise 'oops' unless (zeroto4 + between4and6 + over6) == 1

  puts "current value: #{data[-1]['datetime']}, #{data[-1]['kp']}"
  puts "steps until window starts: #{STEPS_UNTIL_WINDOW}"
  puts "steps within window: #{STEPS_WITHIN_WINDOW}"

  puts 'forecast:'
  puts "zero to 4: #{zeroto4}"
  puts "4.01 to 6: #{between4and6}"
  puts "4.01 to 5: #{between4and5}"
  puts "5.01 to 6: #{between5and6}"
  puts "over 6: #{over6}"
end

def naive_baserate(data, timerange)
  period = data.select { |row| timerange.cover?(row['datetime']) }.map { |row| row['kp'].to_f }
  frequencies = period.each_slice(STEPS_WITHIN_WINDOW).map(&:max).group_by do |x|
    if x <= 4
      '4 or less'
    elsif x <= 5
      '4.01 to 5'
    elsif x <= 6
      '5.01 to 6'
    else
      'greater than 6'
    end
  end

  chunks = frequencies.values.map(&:size).sum
  frequencies.transform_values { |v| v.size.to_f / chunks }
end

p naive_baserate(data, ('2023-01-01'..))
