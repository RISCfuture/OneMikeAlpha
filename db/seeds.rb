# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

require 'timezone_loader'
require 'airport_loader/fadds'
require 'airport_loader/icao'

TimezoneLoader.instance.load!
AirportLoader::FADDS.instance.load!
AirportLoader::ICAO.instance.load!
Airport.batch_update_timezones!
