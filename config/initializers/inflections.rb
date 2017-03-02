# Be sure to restart your server when you modify this file.

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular 'valve', 'valves'
  inflect.uncountable %w[aircraft telemetry]
  inflect.acronym 'JWT'
  inflect.acronym 'API'
end
