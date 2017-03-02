require 'workflow'

# TODO: only one at a time per aircraft

class ImportWorkflow < Workflow
  def perform(upload)
    run :start_processing_upload, upload

    if (importer = batch_importer(upload))
      run :batch_import, importer.to_s, upload
    else
      parallel do
        upload.each_file_importer { |i| run :process_import, i }
      end
    end

    run :create_telemetry_positions, upload

    run :create_flights, upload.aircraft
    run :update_flights, upload.aircraft

    run :complete_processing_upload, upload
  end

  step :start_processing_upload do |upload|
    upload.update_attribute :state, :processing
  end

  step :process_import, &:process!

  step :batch_import do |importer, upload|
    importer.constantize.new(upload).import!
  end

  step :create_telemetry_positions do |upload|
    Telemetry::PositionSensor.regenerate_positions! aircraft:   upload.aircraft,
                                                    time_range: upload.time_range
  end

  step :create_flights, &:create_or_update_flights!

  step :update_flights do |aircraft|
    aircraft.flights.where(significant: nil)._significant.update_all significant: true
    aircraft.flights.where(significant: nil)._not_significant.update_all significant: false

    aircraft.flights.includes(:origin, :destination).find_each { |f| f.update slug: nil }
  end

  step :complete_processing_upload do |upload|
    upload.update_attribute :state, :finished
  end

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
