require 'rails_helper'

RSpec.describe Runway, type: :model do
  describe '#airport' do
    it "should return the airport for a FADDS runway" do
      airport = FactoryBot.create(:airport, :fadds)
      # red herrings
      FactoryBot.create :airport, :fadds
      FactoryBot.create :airport, :icao

      runway = FactoryBot.build(:runway, :fadds, fadds_site_number: airport.fadds_site_number)
      expect(runway.airport).to eql(airport)
    end

    it "should return the airport for an ICAO runway" do
      airport = FactoryBot.create(:airport, :icao)
      # red herrings
      FactoryBot.create :airport, :fadds
      FactoryBot.create :airport, :icao

      runway = FactoryBot.build(:runway, :icao, icao_airport_number: airport.icao_number)
      expect(runway.airport).to eql(airport)
    end
  end

  describe '#fadds_record?' do
    it "should return true if the runway is a FADDS record or false if it is ICAO" do
      expect(FactoryBot.build(:runway, :fadds)).to be_fadds_record
      expect(FactoryBot.build(:runway, :icao)).not_to be_fadds_record
    end
  end

  describe '#icao_record?' do
    it "should return true if the runway is an ICAO record or false if it is FADDS" do
      expect(FactoryBot.build(:runway, :icao)).to be_icao_record
      expect(FactoryBot.build(:runway, :fadds)).not_to be_icao_record
    end
  end
end
