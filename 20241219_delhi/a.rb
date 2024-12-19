#!/usr/bin/env ruby

require 'open-uri'
require 'csv'
require 'time'
require 'json'

url = 'https://dosairnowdata.org/dos/historical/NewDelhi/2024/NewDelhi_PM2.5_2024_12_MTD.csv'
csv_file_path = 'mtd.csv'

data = URI.open(url).read

csv = CSV.parse(data, headers: true)

csv_count = csv.select { |row| row['Day'].to_i >= 16 }.size
csv_hazardous = csv.select { |row| row['Day'].to_i >= 16 && row['AQI Category'] == 'Hazardous' }.size

TOTAL_HOURS=336
TARGET_HOURS=TOTAL_HOURS/3

csv_end_datetime = Time.parse(csv[-1]['Date (LT)'])

URL = "https://www.dosairnowdata.org/dos/AllPosts24Hour.json"

recent_data = JSON.parse(URI.open(URL).read)
recent_data_start_time = Time.strptime(recent_data['New Delhi']['monitors'][0]['beginTimeLT'], '%m/%d/%Y %I:%M:%S %p')
recent_data_aqis = recent_data['New Delhi']['monitors'][0]['aqiCat']

recent_data_start_time_diff = (csv_end_datetime - recent_data_start_time).to_i / 3600

recent_data_hazardous = recent_data_aqis[recent_data_start_time_diff..-1].select { |aqi| aqi >= 6 }.size
recent_data_elapsed = recent_data_aqis[recent_data_start_time_diff..-1].size

total_elapsed = csv_count+recent_data_elapsed
total_hazardous = csv_hazardous+recent_data_hazardous

elapsed = total_elapsed / TOTAL_HOURS.to_f
budget_used = total_hazardous / TARGET_HOURS.to_f
budget_remaining = TARGET_HOURS-total_hazardous
run_rate = total_hazardous.to_f / total_elapsed
required_run_rate_for_no = budget_remaining / (TOTAL_HOURS-total_elapsed).to_f

puts "#{(elapsed * 100).round(1)}% elapsed"
puts "#{(budget_used * 100).round(1)}% budget used"
puts "#{budget_remaining} hazardous hours left to yes"
puts "#{(run_rate * 100).round(1)}% avg run rate (33% target)"
puts "#{(required_run_rate_for_no * 100).round(1)}% max future run rate for no"