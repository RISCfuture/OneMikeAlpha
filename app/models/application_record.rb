class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # we never use STI
  def self.inheritance_column() nil end
end
