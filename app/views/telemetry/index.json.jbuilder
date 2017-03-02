json.interval @interval
json.time_range [@time.first, @time.last]

json.telemetry do
  @telemetry.each do |key_path, data|
    json.set!(key_path.to_s) do
      json.array!(data.map { |time, value| [(time.to_f * 1000).round, value] })
    end
  end
end
