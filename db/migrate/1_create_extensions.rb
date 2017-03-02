class CreateExtensions < ActiveRecord::Migration[5.2]
  EXTENSIONS = %w[postgis file_fdw timescaledb].freeze

  # def change
  #   EXTENSIONS.each { |e| enable_extension e.to_sym }
  # end

  def up
    EXTENSIONS.each do |extension|
      sudo "CREATE EXTENSION IF NOT EXISTS #{extension} CASCADE"
    end

    # foreign data wrapper for file imports using SELECT
    sudo "CREATE SERVER file_import FOREIGN DATA WRAPPER file_fdw"
    sudo "ALTER SERVER file_import OWNER TO #{ActiveRecord::Base.connection_db_config.configuration_hash[:username].inspect}"
  end

  def down
    sudo "DROP SERVER file_import"

    EXTENSIONS.each do |extension|
      sudo "DROP EXTENSION #{extension}"
    end
  end

  private

  def sudo(query)
    system OneMikeAlpha::Configuration.psql.path,
           '-c',
           query,
           ActiveRecord::Base.connection_db_config.database
  end
end
