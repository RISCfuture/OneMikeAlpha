xml.gpx(xmlns:               'http://www.topografix.com/GPX/1/1',
        'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
        creator:             'OneMikeAlpha',
        version:             '1.1',
        'xsi:schemaLocation' => 'http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd') do
  xml.metadata do
    xml.name short_description(@flight)
    xml.time @flight.departure_time.xmlschema
    xml.bounds minlat: @flight.bounds[0][0], maxlat: @flight.bounds[1][0],
               minlon: @flight.bounds[0][1], maxlon: @flight.bounds[1][1]
  end

  xml.trk do
    xml.number 1
    xml.trkseg do
      @telemetry.each do |telemetry|
        next if [telemetry.longitude, telemetry.latitude, telemetry.altitude].any?(&:nil?)

        xml.trkpt(lat: telemetry.latitude, lon: telemetry.longitude) do
          xml.ele telemetry.altitude.to('m').scalar
          xml.time telemetry.bucket.xmlschema
        end
      end
    end
  end
end
