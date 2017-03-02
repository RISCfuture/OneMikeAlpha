json.call upload, :id, :state, :created_at

json.destroyed upload.destroyed?

json.files do
  json.array!(upload.files) do |file|
    json.call file, :filename, :byte_size
  end
end
