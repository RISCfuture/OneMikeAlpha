class Timezone < ApplicationRecord
  include Geography

  geo_column :boundaries, type: :polygon

  validates :name,
            presence:   true,
            uniqueness: true,
            inclusion:  {in: TZInfo::Timezone.all.map(&:name)}
  validates :boundaries,
            presence: true
end
