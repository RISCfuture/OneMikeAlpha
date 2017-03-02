require 'workflow'
require 'importer/batch/base'

class MultiImportWorkflow < Workflow
  def perform(aircraft, uploads)
    parallel do
      uploads.each { |upload| run :start_processing_upload, upload }
    end

    parallel do
      uploads.each do |upload|
        if (importer = batch_importer(upload))
          run :batch_import, importer.to_s, upload
        else
          upload.each_file_importer { |i| run :process_import, i }
        end
      end
    end

    run :create_telemetry_positions, aircraft

    run :create_flights, aircraft
    run :update_flights, aircraft

    parallel do
      uploads.each { |upload| run :complete_processing_upload, upload }
    end
  end

  step :start_processing_upload, &:start

  step :process_import, &:process!

  step :batch_import do |importer, upload|
    require importer.underscore
    importer.constantize.new(upload).import!
  end

  step :create_telemetry_positions do |aircraft|
    Telemetry::PositionSensor.regenerate_positions! aircraft: aircraft
  end

  step :create_flights, &:create_or_update_flights!

  step :update_flights do |aircraft|
    aircraft.flights.where(significant: nil)._significant.update_all significant: true
    aircraft.flights.where(significant: nil)._not_significant.update_all significant: false

    aircraft.flights.includes(:origin, :destination).find_each { |f| f.update slug: nil }
  end

  step :complete_processing_upload, &:finish

  on_error do |_error, step, *args|
    case step
      when :start_processing_upload
        upload = args[0]
        upload.fail I18n.t('workflow.import.error.start_processing_upload')
      when :process_import
        file_importer = args[0]
        upload        = file_importer.file.record
        upload.fail I18n.t('workflow.import.error.process_import', filename: file_importer.filename)
      when :batch_import
        upload = args[1]
        upload.fail I18n.t('workflow.import.error.batch_import')
      when :create_telemetry_positions
        upload = args[0]
        upload.fail I18n.t('workflow.import.error.create_telemetry_positions')
      when :complete_processing_upload
        upload = args[0]
        upload.fail I18n.t('workflow.import.error.complete_processing_upload')
    end
  end

  private

  def batch_importer(upload)
    upload.aircraft.importers.detect { |i| i.ancestors.include?(Importer::Batch::Base) && i.can_import?(upload) }
  end
end
