require 'optparse'
require 'shellwords'

require 'importer/file/avidyne_r9'

options = {
    path: "#{ENV['HOME']}/Dropbox/Project Chute/N171MA/Operation Records/R9 Data Logs"
}

OptionParser.new do |opts|
  opts.on('-eEMAIL', '--email=EMAIL', "Email of new (or existing) account") do |e|
    options[:email] = e
  end
  opts.on('-pPASS', '--password=PASS', "Password of new (or existing) account") do |p|
    options[:password] = p
  end
  opts.on('-i', '--[no-]inline', "Run import inline rather than using Active Job") do |i|
    options[:inline] = i
  end
  opts.on('-P', '--path=PATH', "Path to import logs from") do |p|
    options[:path] = p
  end
  opts.on('-d', '--[no-]destroy', "Destroy existing telemetry data") do
    options[:destroy] = true
  end
end.parse!

if options[:email].blank?
  print "New email: "
  options[:email] = gets.chomp
end
if options[:password].blank?
  print "New password: "
  options[:password] = gets.chomp
end

user     = User.where(email: options[:email]).create_or_update!(password: options[:password])
aircraft = Aircraft.where(registration: 'N171MA').
    create_or_update!(aircraft_data:  'Cirrus/SR22/G2/TATurbo',
                      equipment_data: 'Avidyne/EntegraR9')
Permission.where(user_id: user.id, aircraft_id: aircraft.id).create_or_update!(level: :admin)

if options[:destroy]
  Upload.destroy_all # remove attached files

  [Upload, Flight, WorkflowStep, *Telemetry.telemetry_classes.to_a].each do |m|
    m.connection.execute "TRUNCATE #{m.quoted_table_name} RESTART IDENTITY CASCADE"
  end
end

uploads = Array.new
if Dir.children(options[:path]).any? { |child| File.directory? File.join(options[:path], child) }
  Dir.each_child(options[:path]) do |subdir_name|
    subdir = File.join(options[:path], subdir_name)
    next unless File.directory?(subdir)

    upload = Upload.create! aircraft: aircraft, user: user
    upload.import_path(subdir) { |f| Importer::File::AvidyneR9.can_import?(f) }
    uploads << upload
  end
elsif File.directory?(options[:path])
  upload = Upload.create! aircraft: aircraft, user: user
  upload.import_path(options[:path]) { |f| Importer::File::AvidyneR9.can_import?(f) }
  uploads << upload
else
  raise "#{options[:path]} not a directory"
end

Rails.application.operation_logger.tagged('local_import') do
  if options[:inline]
    uploads.each_with_index do |u, index|
      Rails.application.operation_logger.info "Processing #{index + 1} of #{uploads.size}"
      u.process_inline!
    end

    Telemetry::PositionSensor.regenerate_positions! aircraft: aircraft
    aircraft.create_or_update_flights!
    aircraft.flights.where(significant: nil)._significant.update_all significant: true
    aircraft.flights.where(significant: nil)._not_significant.update_all significant: false
    aircraft.flights.includes(:origin, :destination).find_each { |f| f.update slug: nil }

    uploads.each(&:finish)
  else
    Rails.application.operation_logger.info "Enqueuing #{uploads.size} Upload jobs"
    uploads.each { |u| ImportWorkflow.perform_later(u) }
  end
end
