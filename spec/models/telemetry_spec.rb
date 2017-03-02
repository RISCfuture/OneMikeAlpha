require 'rails_helper'

RSpec.describe Telemetry, type: :model do
  describe '#time_range' do
    let(:telemetry) { FactoryBot.create(:telemetry, time: Time.utc(1982, 10, 19, 12, 10), interval: 300) }

    it "should return the range of times applicable to this telemetry" do
      expect(telemetry.time_range).to be_kind_of(Range)
      expect(telemetry.time_range.first).to eql(Time.utc(1982, 10, 19, 12, 7, 30))
      expect(telemetry.time_range.last).to eql(Time.utc(1982, 10, 19, 12, 12, 30))
    end
  end
end
