require 'tmpdir'
require 'shellwords'
require 'open-uri'

require 'bulk_inserter'

class TimezoneLoader
  include Singleton

  def load!
    Rails.application.operation_logger.tagged(self.class.to_s) do
      download do |tmpdir, zipfile|
        unzip tmpdir, zipfile
        load_shapes tmpdir
      end
    end
  end

  private

  def download
    Rails.application.operation_logger.info "Downloading"

    Dir.mktmpdir do |dir|
      client  = Octokit::Client.new(login:    Rails.application.credentials.github_username,
                                    password: Rails.application.credentials.github_token)
      release = client.latest_release(OneMikeAlpha::Configuration.timezone_loader.github_repo)
      asset   = release.assets.detect { |a| a.name == OneMikeAlpha::Configuration.timezone_loader.filename }

      # not sure why we have to do this part with cURL, but whatever…
      Dir.chdir(dir) do
        Rails.application.operation_logger.system 'curl', '-LJO',
                                                  '-H', 'Accept: application/octet-stream',
                                                  '-u' "#{Rails.application.credentials.github_username}:#{Rails.application.credentials.github_token}",
                                                  asset.url
      end

      path = File.join(dir, 'timezones-with-oceans.shapefile.zip')
      yield dir, path
    end
  end

  SHAPE_FILES = %w[dbf prj shp shx].map { |ext| "combined-shapefile-with-oceans.#{ext}" }.freeze
  private_constant :SHAPE_FILES

  def unzip(tmpdir, zipfile)
    Rails.application.operation_logger.info "Unzipping"

    Zip::Archive.open(zipfile) do |ar|
      ar.each do |zf|
        next if zf.directory?

        name = File.basename(zf.name)
        next unless SHAPE_FILES.include?(name)

        File.open(File.join(tmpdir, name), 'wb') do |f|
          f << zf.read
        end
      end
    end
  end

  def load_shapes(tmpdir)
    Rails.application.operation_logger.info "Inserting"

    shapes = Dir.glob(File.join(tmpdir, '*.shp')).first

    if OneMikeAlpha::Configuration.psql[:shp2pgsql_path] && File.exist?(OneMikeAlpha::Configuration.psql.shp2pgsql_path) &&
        OneMikeAlpha::Configuration.psql[:path] && File.exist?(OneMikeAlpha::Configuration.psql.path)
      load_shapes_the_easy_way tmpdir, shapes
    else
      load_shapes_the_hard_way shapes
    end
  end

  def load_shapes_the_easy_way(tmpdir, shapes)
    mappings = File.join(tmpdir, 'mappings.txt')
    File.open(mappings, 'w') { |f| f.puts COLUMN_MAPPINGS }

    sql_file = File.join(tmpdir, 'shapes.sql')
    `#{Shellwords.escape OneMikeAlpha::Configuration.psql.shp2pgsql_path} -G -s 4326 -g boundaries -a -m #{mappings} #{Shellwords.escape shapes} timezones > #{Shellwords.escape sql_file}`

    db_options   = Timezone.connection_config
    psql_options = +''
    psql_options << '-U' << Shellwords.escape(db_options[:username]) if db_options[:username]
    psql_options << '-h' << Shellwords.escape(db_options[:host]) if db_options[:host]
    psql_options << '-p' << Shellwords.escape(db_options[:port]) if db_options[:port]
    psql_options << ' ' << Shellwords.escape(db_options[:database])
    env = db_options[:password] ? "PGPASSWORD=#{Shellwords.escape db_options[:password]}" : nil

    Timezone.connection.execute "TRUNCATE timezones"
    `#{env} #{Shellwords.escape OneMikeAlpha::Configuration.psql.path} #{psql_options} < #{Shellwords.escape sql_file}`

    Timezone.pluck(:name).each do |name|
      TZInfo::Timezone.get(name)
    rescue StandardError
      Timezone.delete_by(name: name)
    end
  end

  COLUMN_MAPPINGS = 'name tzid'.freeze

  def load_shapes_the_hard_way(shapes)
    Timezone.connection.execute "TRUNCATE timezones"
    RGeo::Shapefile::Reader.open(shapes) do |file|
      BulkInserter.upsert!(Timezone, exclude: %i[id]) do |importer|
        file.each do |record|
          begin
            TZInfo::Timezone.get(record['tzid'])
          rescue StandardError
            next
          end
          importer << {name: record['tzid'], boundaries: record.geometry}
        end
      end
    end
  end
end
