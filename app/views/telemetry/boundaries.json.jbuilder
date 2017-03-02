json.interval @interval
json.time_range [@time.first, @time.last]

json.boundaries do
  json.array!(@boundaries) do |(time, value)|
    json.array! [(time.to_f * 1000).round, value]
  end
end
