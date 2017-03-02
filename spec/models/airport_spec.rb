require 'rails_helper'

RSpec.describe Airport, type: :model do
  context '[validations]' do
    it "should require an FAA or ICAO identifier" do
      airport = FactoryBot.build(:airport, fadds_site_number: nil, icao_number: nil)
      expect(airport).not_to be_valid
      expect(airport.errors[:base]).to eql(["must have either an FADDS site code or ICAO CSV identifier"])
    end
  end

  context '[hooks]' do
    it "should set a timezone" do
      skip "way too slow"
      FactoryBot.create :timezone
      airport = FactoryBot.create(:airport, :fadds, location: Geography.geo_factory.point(-122.4, 37.8, 0))
      expect(airport.timezone).to eql('America/Los_Angeles')
    end
  end

  describe '#runways' do
    it "should return the runways for a FADDS record" do
      airport = FactoryBot.create(:airport, :fadds)
      runways = FactoryBot.create_list(:runway, 2, :fadds, airport: airport)
      FactoryBot.create :runway, :fadds, fadds_site_number: '01234.*B' # red herring
      expect(airport.runways).to match_array(runways)
    end

    it "should return the runways for an ICAO record" do
      airport = FactoryBot.create(:airport, :icao)
      runways = FactoryBot.create_list(:runway, 2, :icao, airport: airport)
      FactoryBot.create :runway, :icao # red herring
      expect(airport.runways).to match_array(runways)
    end
  end

  describe '#fadds_record?' do
    it "should return true if the airport is from FADDS, false otherwise" do
      expect(FactoryBot.build(:airport, :fadds)).to be_fadds_record
      expect(FactoryBot.build(:airport, :icao)).not_to be_fadds_record
    end
  end

  describe '#icao_record?' do
    it "should return true if the airport is from the ICAO DB, false otherwise" do
      expect(FactoryBot.build(:airport, :fadds)).not_to be_icao_record
      expect(FactoryBot.build(:airport, :icao)).to be_icao_record
    end
  end

  describe '#country' do
    it "should return the ISO3166 country object" do
      airport = FactoryBot.build(:airport, :fadds, country_code: 'US')
      expect(airport.country.name).to eql("United States of America")
    end
  end

  describe '#identifier' do
    it "should return the LID if set" do
      airport = FactoryBot.build(:airport, :fadds, lid: 'DVO', icao: 'KDVO', iata: 'NOT')
      expect(airport.identifier).to eql('DVO')
    end

    it "should return the ICAO code if the LID is not set" do
      airport = FactoryBot.build(:airport, :fadds, lid: nil, icao: 'KDVO', iata: 'NOT')
      expect(airport.identifier).to eql('KDVO')
    end

    it "should return the IATA code if neither LID nor ICAO codes are set" do
      airport = FactoryBot.build(:airport, :fadds, lid: nil, icao: nil, iata: 'NOT')
      expect(airport.identifier).to eql('NOT')
    end

    it "should return '---' otherwise" do
      airport = FactoryBot.build(:airport, :fadds, lid: nil, icao: nil, iata: nil)
      expect(airport.identifier).to eql('---')
    end
  end

  describe '#tzinfo' do
    it "should return the timezone object" do
      airport = FactoryBot.build(:airport, timezone: 'America/Los_Angeles')
      expect(airport.tzinfo.name).to eql('America/Los_Angeles')
    end

    it "should return nil if the timezone is not set" do
      airport = FactoryBot.build(:airport, timezone: nil)
      expect(airport.tzinfo).to be_nil
    end
  end

  describe '.batch_update_timezones!' do
    it "should batch set timezones for all airports" do
      skip "way too slow"
      FactoryBot.create :timezone
      airport = FactoryBot.create(:airport, :fadds, location: Geography.geo_factory.point(-122.4, 37.8, 0))
      airport.update_column :timezone, nil
      described_class.batch_update_timezones!
      expect(airport.reload.timezone).to eql('America/Los_Angeles')
    end
  end
end
