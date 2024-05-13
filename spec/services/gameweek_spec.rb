require 'rails_helper'

RSpec.describe Gameweek, type: :service do
  # your tests go here
  let(:api_data) { JSON.parse(File.read("./test/fixtures/api_data.json")) }
  let(:end_of_season_data) { JSON.parse(File.read("./test/fixtures/end_of_season_data.json")) }
  let(:time_relative) { "next" }
  let(:gameweek) { Gameweek.new(api_data, time_relative) }
  let(:end_of_season_gameweek) { Gameweek.new(end_of_season_data, time_relative) }

  describe '#gw_num' do
    it 'returns the correct gameweek number' do
      # Replace 'expected_gw_num' with the expected gameweek number
      expected_gw_num = 36
      expect(gameweek.gw_num).to eq(expected_gw_num)
    end
  end

  describe '#deadline' do
    it 'returns the correct deadline time' do
      # Replace 'expected_deadline' with the expected deadline time
      expected_deadline = Time.zone.parse("2024-05-03T17:30:00Z").in_time_zone("London")
      expect(gameweek.deadline).to eq(expected_deadline)
    end
  end

  describe 'returns 38 at the end of the season' do
    it 'returns 38 as the gameweek number at the end of the season' do
      expect(end_of_season_gameweek.gw_num).to eq(38)
    end
  end

  describe 'returns GW38s deadline at the end of the season' do
    it 'returns 38 deadline as the gameweek deadline at the end of the season' do
      expected_deadline = Time.zone.parse("2024-05-19T13:30:00Z").in_time_zone("London")
      expect(end_of_season_gameweek.deadline).to eq(expected_deadline)
    end
  end

end
