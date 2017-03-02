module Importer
  def self.batch_importers
    Importer::Batch::Base.subclasses
  end

  def self.file_importers
    Importer::File::Base.subclasses
  end
end
