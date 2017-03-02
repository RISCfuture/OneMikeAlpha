json.call upload, :state, :created_at

json.files do
  json.array!(upload.files) do |file|
    json.call file, :filename, :byte_size
  end
end
