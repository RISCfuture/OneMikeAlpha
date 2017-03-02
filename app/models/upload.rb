require 'find'
require 'multi_table_bulk_inserter'

class Upload < ApplicationRecord
  enum state: %i[pending processing finished failed]

  has_many_attached :files

  belongs_to :user
  belongs_to :aircraft

  validates :workflow_uuid,
            format:    {with: /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/},
            allow_nil: true

  after_commit { UploadsChannel.broadcast_to aircraft, self }

  state_machine initial: :pending do
    event(:start) { transition pending: :processing }
    event(:finish) { transition processing: :finished }
    event(:fail) { transition processing: :failed }

    def fail(error, *args)
      self.error = error
      super(*args)
    end
  end

  def import_path(path)
    find_files(path).each do |file|
      next if block_given? && !yield(file)

      files.attach(io: file.open, filename: file.basename)
    end
  end

  def process!
    workflow = ImportWorkflow.perform_later(self)
    update_attribute :workflow_uuid, workflow.id
  end

  def process_inline!
    ImportWorkflow.perform_inline(self) do |workflow|
      update_attribute :workflow_uuid, workflow.id
    end
  end

  def workflow_progress
    in_progress_steps = WorkflowStep.where(workflow_uuid: workflow_uuid, processing: true).count
    pending_steps     = WorkflowStep.where(workflow_uuid: workflow_uuid, processing: false).count
    completed_steps   = workflow.step_count - in_progress_steps - pending_steps
    return (in_progress_steps*0.5 + completed_steps)/workflow.step_count.to_f
  end

  def each_file_importer
    return enum_for(:each_file_importer) unless block_given?

    files.find_each { |file| yield FileImporter.new(file) }
  end

  def time_range
    return nil unless earliest_time? && latest_time?

    return earliest_time..latest_time
  end

  private

  def workflow
    ImportWorkflow.new(id: workflow_uuid, arguments: [self])
  end

  def find_files(*search_paths)
    paths = Set.new
    search_paths.each do |path|
      pathname = Pathname.new(path).realpath
      if pathname.directory?
        Find.find(pathname) do |subpath|
          subpathname = Pathname.new(subpath).realpath
          next if subpathname.directory?
          next if subpathname.basename.to_s.start_with?('.')

          paths << subpathname
        end
      else
        next if pathname.directory?
        next if pathname.basename.to_s.start_with?('.')

        paths << pathname
      end
    end

    return paths
  end

  class FileImporter
    include GlobalID::Identification

    attr_reader :file

    delegate :blob, :filename, to: :file
    def initialize(file)
      @file = file
    end

    def upload = file.record

    def process!
      download(&method(:import_from_file))
    end

    def download
      blob.open(tmpdir: Dir.tmpdir) { |file| yield file }
    end

    def importer
      upload.aircraft.importers.detect do |i|
        i.ancestors.include?(Importer::File::Base) &&
          i.can_import?(filename)
      end
    end

    def import_from_file(tmpfile)
      return unless importer

      Rails.root.join('app', 'models', 'telemetry').glob('**/*.rb').each { |f| require f.to_s }

      upserter = MultiTableBulkInserter.new(strategy: :multi_upsert)
      Telemetry.telemetry_classes.each do |klass|
        upserter.add_class klass, merge_keys: klass.primary_key
      end

      upserter.run! do
        importer.new(upload.aircraft, tmpfile.path).import!(filename.to_s) do |type, record|
          upserter.add type, record
        end
      end
    end

    # for GlobalID

    # @private
    def id = file.id
    # @private
    def self.find(id) = FileImporter.new(ActiveStorage::Attachment.find(id))
  end

  private_constant :FileImporter
end
