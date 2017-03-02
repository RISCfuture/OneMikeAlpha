xml.kml(xmlns: 'http://www.opengis.net/kml/2.2', 'xmlns:gx' => 'http://www.google.com/kml/ext/2.2') do
  xml.Document do
    xml.open 1
    xml.visibility 1
    xml.Style(id: FlightsHelper::TRACK_STYLE_ID) do
      xml.LineStyle do
        xml.color FlightsHelper::TRACK_STYLE_COLOR
        xml.width 4
      end
      xml.PolyStyle do
        xml.color FlightsHelper::TRACK_STYLE_FILL
      end
    end
    xml.Style(id: FlightsHelper::PATH_STYLE_ID) do
      xml.LineStyle FlightsHelper::PATH_STYLE_COLOR
      xml.width 8
    end

    xml.Placemark do
      xml.name short_description(@flight)
      xml.description long_description(@flight)
      xml.styleUrl FlightsHelper::TRACK_STYLE_REF
      xml.gx :Track do
        xml.altitudeMode 'absolute'
        xml.extrude 1
        xml.gx :interpolate, 1

        @telemetry.each do |telemetry|
          next if [telemetry.longitude, telemetry.latitude, telemetry.altitude].any?(&:nil?)

          xml.when telemetry.bucket.xmlschema
          xml.gx :coord, [telemetry.longitude, telemetry.latitude, telemetry.altitude.to('m').scalar].join(' ')
          if telemetry.true_heading && telemetry.pitch && telemetry.roll
            xml.gx :angles, [telemetry.true_heading, telemetry.pitch, telemetry.roll].map { |t| t.to('deg').scalar }.join(' ')
          end
        end
      end
    end

    xml.Placemark do
      xml.name t('views.flights.show.kml.placemark.start', origin: or_placeholder(@flight, :origin))
      xml.Point do
        t = @boundaries.first
        xml.coordinates "#{t.position.x} #{t.position.y}"
      end
    end

    xml.Placemark do
      xml.name t('views.flights.show.kml.placemark.end', destination: or_placeholder(@flight, :destination))
      xml.Point do
        t = @boundaries.last
        xml.coordinates "#{t.position.x} #{t.position.y}"
      end
    end

    xml.ExtendedData do
      xml.SchemaData do
        xml.gx :SimpleArrayData, name: 'acc_horiz' do
          @telemetry.each do |t|
            next if [t.longitude, t.latitude, t.altitude].any?(&:nil?)

            xml.gx :value, t.horizontal_figure_of_merit.to('m').scalar
          end
        end
      end

      xml.Data(name: 'source') do
        xml.displayName t('views.flights.show.kml.source')
        xml.value t("equipment.#{@aircraft.equipment_data.split(',').first}")
      end
      xml.Data(name: 'flightTitle') do
        xml.value short_description(@flight)
      end
    end
  end
end
