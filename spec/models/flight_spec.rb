require 'rails_helper'

RSpec.describe Flight, type: :model do
  context '[validations]' do
    it "should ensure that the recording start time comes before the end time" do
      flight = FactoryBot.build(:flight, recording_end_time: 2.days.ago, recording_start_time: 1.day.ago)
      expect(flight).not_to be_valid
      expect(flight.errors[:recording_end_time]).to eql(["must come after start time"])
    end

    it "should ensure that the movement start time comes before the end time" do
      pending "no way to test this"
      flight = FactoryBot.build(:flight, arrival_time: 2.days.ago, departure_time: 1.day.ago)
      expect(flight).not_to be_valid
      expect(flight.errors[:arrival_time]).to eql(["must come after start time"])
    end
  end

  context '[scopes]' do
    context 'covering_range' do
      let(:start_time) { 2.hours.ago }
      let(:end_time) { 1.hour.ago }

      it "should exclude flights starting and ending before the range" do
        flight = FactoryBot.create(:flight,
                                   recording_start_time: start_time - 2.hours,
                                   recording_end_time:   start_time - 1.hour)
        expect(described_class.covering_range(start_time, end_time)).not_to include(flight)
      end

      it "shoud include flights beginning before the range and ending within the range" do
        flight = FactoryBot.create(:flight,
                                   recording_start_time: start_time - 1.hour,
                                   recording_end_time:   start_time + 30.minutes)
        expect(described_class.covering_range(start_time, end_time)).to include(flight)
      end

      it "shoud include flights beginning before the range and ending after the range" do
        flight = FactoryBot.create(:flight,
                                   recording_start_time: start_time - 1.hour,
                                   recording_end_time:   start_time + 2.hours)
        expect(described_class.covering_range(start_time, end_time)).to include(flight)
      end

      it "should include flights beginning and ending within the range" do
        flight = FactoryBot.create(:flight,
                                   recording_start_time: start_time + 15.minutes,
                                   recording_end_time:   end_time - 15.minutes)
        expect(described_class.covering_range(start_time, end_time)).to include(flight)
      end

      it "should include flights beginning within the range and ending after the range" do
        flight = FactoryBot.create(:flight,
                                   recording_start_time: start_time + 30.minutes,
                                   recording_end_time:   end_time + 1.hour)
        expect(described_class.covering_range(start_time, end_time)).to include(flight)
      end

      it "should exclude flights beginning and ending after the range" do
        flight = FactoryBot.create(:flight,
                                   recording_start_time: end_time + 1.hour,
                                   recording_end_time:   end_time + 2.hours)
        expect(described_class.covering_range(start_time, end_time)).not_to include(flight)
      end
    end

    describe 'significant' do
      let(:time) { Time.now }
      let(:aircraft) { FactoryBot.create :aircraft }

      it "should include significant flights" do
        too_short = FactoryBot.build(:flight, aircraft: aircraft, recording_start_time: time, recording_end_time: time+5.seconds)
        FactoryBot.create :telemetry, aircraft: aircraft, time: time+1.second, gps_height_agl: 1, ground_speed: 5
        FactoryBot.create :telemetry, aircraft: aircraft, time: time+4.seconds, gps_height_agl: 100, ground_speed: 5
        too_short.save!

        no_alt_change = FactoryBot.build(:flight, aircraft: aircraft, recording_start_time: time+1.hour, recording_end_time: time+2.hours)
        FactoryBot.create :telemetry, aircraft: aircraft, time: time+1.1.hour, gps_height_agl: 1, ground_speed: 5
        FactoryBot.create :telemetry, aircraft: aircraft, time: time+1.9.hours, gps_height_agl: 5, ground_speed: 5
        no_alt_change.save!

        significant = FactoryBot.build(:flight, aircraft: aircraft, recording_start_time: time+3.hours, recording_end_time: time+4.hours)
        FactoryBot.create :telemetry, aircraft: aircraft, time: time+3.1.hours, gps_height_agl: 1, ground_speed: 5
        FactoryBot.create :telemetry, aircraft: aircraft, time: time+3.9.hours, gps_height_agl: 500, ground_speed: 5
        significant.save!

        expect(described_class._significant.to_a).to match_array([significant])
      end
    end
  end

  describe '#telemetry' do
    let(:start_time) { 2.hours.ago }
    let(:end_time) { 1.hour.ago }
    let(:aircraft) { FactoryBot.create :aircraft }

    it "should return an empty relation if recording period isn't set" do
      expect(FactoryBot.build(:flight, recording_start_time: nil, recording_end_time: nil).telemetry).to be_empty
    end

    it "should return a relation" do
      t2 = FactoryBot.create(:telemetry, aircraft: aircraft, time: start_time + 30.minutes, interval: 3)
      t1 = FactoryBot.create(:telemetry, aircraft: aircraft, time: start_time + 15.minutes, interval: 3)
      # red herrings
      FactoryBot.create :telemetry, aircraft: aircraft, time: start_time - 15.minutes, interval: 3 # outside range
      FactoryBot.create :telemetry, time: start_time + 15.minutes, interval: 3 # wrong aircraft
      FactoryBot.create :telemetry, aircraft: aircraft, time: start_time + 15.minutes, interval: 30 # wrong interval

      flight = FactoryBot.build(:flight, aircraft: aircraft, recording_start_time: start_time, recording_end_time: end_time)
      expect(flight.telemetry.to_a).to eql([t1, t2])
    end

    it "should accept a interval" do
      t2 = FactoryBot.create(:telemetry, aircraft: aircraft, time: start_time + 30.minutes, interval: 30)
      t1 = FactoryBot.create(:telemetry, aircraft: aircraft, time: start_time + 15.minutes, interval: 30)
      # red herrings
      FactoryBot.create :telemetry, aircraft: aircraft, time: start_time + 15.minutes, interval: 3 # wrong interval

      flight = FactoryBot.build(:flight, aircraft: aircraft, recording_start_time: start_time, recording_end_time: end_time)
      expect(flight.telemetry(interval: 30).to_a).to eql([t1, t2])
    end
  end

  describe '#recording_period' do
    let(:start_time) { 2.hours.ago }
    let(:end_time) { 1.hour.ago }

    it "should return nil if recording start/end time isn't set" do
      expect(FactoryBot.build(:flight, recording_start_time: nil).recording_period).to be_nil
      expect(FactoryBot.build(:flight, recording_end_time: nil).recording_period).to be_nil
    end

    it "should return the recording period range" do
      flight = FactoryBot.build(:flight, recording_start_time: start_time, recording_end_time: end_time)
      expect(flight.recording_period).to eql(start_time..end_time)
    end
  end

  describe '#duration' do
    let(:start_time) { 2.5.hours.ago }
    let(:end_time) { 1.hour.ago }

    it "should return nil if departure/arrival time isn't set" do
      expect(FactoryBot.build(:flight, departure_time: nil).duration).to be_nil
      expect(FactoryBot.build(:flight, arrival_time: nil).duration).to be_nil
    end

    it "should return the time interval between departure and arrival time" do
      flight = FactoryBot.build(:flight, departure_time: start_time, arrival_time: end_time)
      expect(flight.duration).to be_within(1).of(1.5.hours)
    end
  end

  describe '#recalculate' do
    let(:aircraft) { FactoryBot.create :aircraft }
    let(:origin) { FactoryBot.create(:airport, :fadds, lat: 37.5118549, lon: -122.2495235, elevation: 1.6) }
    let(:destination) { FactoryBot.create(:airport, :fadds, lat: 40.4771111, lon: -88.9159167, elevation: 265.6) }
    let(:recording_start_time) { 5.hours.ago }
    let(:departure_time) { 4.hours.ago }
    let(:takeoff_time) { 3.hours.ago }
    let(:landing_time) { 2.hours.ago }
    let(:arrival_time) { 1.hour.ago }
    let(:recording_end_time) { Time.now }

    it "should recalculate times and geolocations" do
      # origin telemetry
      FactoryBot.create :telemetry, :position, aircraft: aircraft, time: recording_start_time, position: origin.location
      # destination telemetry
      FactoryBot.create :telemetry, :position, aircraft: aircraft, time: recording_end_time, position: destination.location
      # departure telemetry
      FactoryBot.create :telemetry, :position, aircraft: aircraft, time: departure_time, ground_speed: 5
      # arrival telemetry
      FactoryBot.create :telemetry, :position, aircraft: aircraft, time: arrival_time, ground_speed: 5
      # takeoff telemetry
      FactoryBot.create :telemetry, :position, aircraft: aircraft, time: takeoff_time, ground_speed: 90, vertical_speed: 110
      # landing telemetry
      FactoryBot.create :telemetry, :position, aircraft: aircraft, time: landing_time, ground_speed: 70, vertical_speed: 90

      flight = FactoryBot.build(:flight, aircraft: aircraft, recording_start_time: recording_start_time, recording_end_time: recording_end_time)
      flight.recalculate
      expect(flight.origin).to eql(origin)
      expect(flight.destination).to eql(destination)
      expect(flight.recording_start_time).to eql(recording_start_time)
      expect(flight.departure_time).to eql(departure_time)
      expect(flight.takeoff_time).to eql(takeoff_time)
      expect(flight.landing_time).to eql(landing_time)
      expect(flight.arrival_time).to eql(arrival_time)
      expect(flight.recording_end_time).to eql(recording_end_time)
    end

    it "should leave takeoff/landing time nil if not found" do
      # origin telemetry
      FactoryBot.create :telemetry, :position, aircraft: aircraft, time: recording_start_time, position: origin.location
      # destination telemetry
      FactoryBot.create :telemetry, :position, aircraft: aircraft, time: recording_end_time, position: destination.location
      # departure telemetry
      FactoryBot.create :telemetry, :position, aircraft: aircraft, time: departure_time, ground_speed: 5
      # arrival telemetry
      FactoryBot.create :telemetry, :position, aircraft: aircraft, time: arrival_time, ground_speed: 5

      flight = FactoryBot.build(:flight,
                                aircraft:             aircraft,
                                recording_start_time: recording_start_time,
                                recording_end_time:   recording_end_time,
                                takeoff_time:         takeoff_time,
                                landing_time:         landing_time)
      flight.recalculate
      expect(flight.takeoff_time).to be_nil
      expect(flight.landing_time).to be_nil
    end

    it "should leave departure/arrival time nil if not found" do
      # origin telemetry
      FactoryBot.create :telemetry, :position, aircraft: aircraft, time: recording_start_time, position: origin.location
      # destination telemetry
      FactoryBot.create :telemetry, :position, aircraft: aircraft, time: recording_end_time, position: destination.location

      flight = FactoryBot.build(:flight,
                                aircraft:             aircraft,
                                recording_start_time: recording_start_time,
                                recording_end_time:   recording_end_time,
                                departure_time:       departure_time,
                                arrival_time:         arrival_time)
      flight.recalculate
      expect(flight.departure_time).to be_nil
      expect(flight.arrival_time).to be_nil
    end

    it "should leave origin/destination nil if not found" do
      # departure telemetry
      FactoryBot.create :telemetry, :position, aircraft: aircraft, time: departure_time, ground_speed: 5
      # arrival telemetry
      FactoryBot.create :telemetry, :position, aircraft: aircraft, time: arrival_time, ground_speed: 5
      # takeoff telemetry
      FactoryBot.create :telemetry, :position, aircraft: aircraft, time: takeoff_time, ground_speed: 90, vertical_speed: 110
      # landing telemetry
      FactoryBot.create :telemetry, :position, aircraft: aircraft, time: landing_time, ground_speed: 70, vertical_speed: 90

      flight = FactoryBot.build(:flight, aircraft: aircraft, recording_start_time: recording_start_time, recording_end_time: recording_end_time)
      flight.recalculate
      expect(flight.origin).to be_nil
      expect(flight.destination).to be_nil
    end
  end

  describe '#should_include?' do
    let(:time) { 1.hour.ago }
    let(:aircraft) { FactoryBot.create :aircraft }
    let(:telemetry) { FactoryBot.create(:telemetry, aircraft: aircraft, time: time) }

    it "should return false if recording start/end time is not set" do
      expect(FactoryBot.build(:flight,
                              aircraft:             aircraft,
                              recording_start_time: nil).
          should_include?(telemetry)).to be(false)
      expect(FactoryBot.build(:flight,
                              aircraft:           aircraft,
                              recording_end_time: nil).
          should_include?(telemetry)).to be(false)
    end

    it "should return true if the time is within 10 seconds of the recording time range" do
      expect(FactoryBot.build(:flight,
                              aircraft:             aircraft,
                              recording_start_time: time+9.seconds,
                              recording_end_time:   time+1.hour).
          should_include?(telemetry)).to be(true)
      expect(FactoryBot.build(:flight,
                              aircraft:             aircraft,
                              recording_start_time: time-1.hour,
                              recording_end_time:   time-9.seconds).
          should_include?(telemetry)).to be(true)
      expect(FactoryBot.build(:flight,
                              aircraft:             aircraft,
                              recording_start_time: time-1.hour,
                              recording_end_time:   time+1.hour).
          should_include?(telemetry)).to be(true)
    end

    it "should return false if outside that range" do
      expect(FactoryBot.build(:flight,
                              aircraft:             aircraft,
                              recording_start_time: time+11.seconds,
                              recording_end_time:   time+1.hour).
          should_include?(telemetry)).to be(false)
      expect(FactoryBot.build(:flight,
                              aircraft:             aircraft,
                              recording_start_time: time-1.hour,
                              recording_end_time:   time-11.seconds).
          should_include?(telemetry)).to be(false)
      expect(FactoryBot.build(:flight,
                              aircraft:             aircraft,
                              recording_start_time: time-2.hours,
                              recording_end_time:   time-1.hour).
          should_include?(telemetry)).to be(false)
    end
  end

  describe '#significant?' do
    let(:aircraft) { FactoryBot.create :aircraft }
    let(:time) { Time.now }

    it "should return false if the flight is too short" do
      flight = FactoryBot.build(:flight, recording_start_time: time, recording_end_time: time + 5.seconds)
      FactoryBot.create :telemetry, aircraft: aircraft, time: time+1.second, ground_speed: 100, gps_height_agl: 1
      FactoryBot.create :telemetry, aircraft: aircraft, time: time+3.seconds, ground_speed: 100, gps_height_agl: 500

      expect(flight).not_to be_significant
    end

    it "should return false if the altitude change is too small" do
      flight = FactoryBot.build(:flight, aircraft: aircraft, recording_start_time: time, recording_end_time: time + 1.hour)
      FactoryBot.create :telemetry, aircraft: aircraft, time: time+1.minute, ground_speed: 100, gps_height_agl: 1
      FactoryBot.create :telemetry, aircraft: aircraft, time: time+59.minutes, ground_speed: 100, gps_height_agl: 3
      expect(flight).not_to be_significant
    end

    it "should return true otherwise" do
      flight = FactoryBot.build(:flight, aircraft: aircraft, recording_start_time: time, recording_end_time: time + 1.hour)
      FactoryBot.create :telemetry, aircraft: aircraft, time: time+1.minute, ground_speed: 100, gps_height_agl: 1
      FactoryBot.create :telemetry, aircraft: aircraft, time: time+59.minutes, ground_speed: 100, gps_height_agl: 300
      flight.recalculate
      expect(flight).to be_significant
    end
  end

  describe '#empty?' do
    it "should return true if recording start/end time is nil" do
      expect(FactoryBot.build(:flight, recording_start_time: nil)).to be_empty
      expect(FactoryBot.build(:flight, recording_end_time: nil)).to be_empty
    end

    it "should return false otherwise" do
      expect(FactoryBot.build(:flight)).not_to be_empty
    end
  end
end
