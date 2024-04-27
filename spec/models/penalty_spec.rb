# spec/models/penalty_spec.rb
require 'rails_helper'

RSpec.describe Penalty, type: :model do
  let(:gameweek) { 35 }
  let(:player_1) { create(:over_15_player) }
  let(:player_2) { create(:over_15_player) }
  let(:player_3) { create(:over_10_player) }
  let(:player_4) { create(:under_10_player) }
  let(:fplteam_1) { create(:fplteam) }
  let(:fplteam_2) { create(:fplteam) }
  let(:illegal_players) { {player_1 => 16, player_2 => 16} }
  let(:last_weeks_free_hitters) { [fplteam_1] }
  let(:api_data) { JSON.parse(File.read("./test/fixtures/api_data.json")) }
  let (:gw35_pick_1) { Pick.create!(player: player_3, fplteam: fplteam_1, gameweek: 35) }
  let (:gw35_pick_2) { Pick.create!(player: player_1, fplteam: fplteam_2, gameweek: 35) }
  let (:gw35_pick_3) { Pick.create!(player: player_4, fplteam: fplteam_1, gameweek: 35) }

  before do
    Pick.create!(player: player_2, fplteam: fplteam_1, gameweek: 33)
    Pick.create!(player: player_1, fplteam: fplteam_2, gameweek: 34)
    Pick.create!(player: player_2, fplteam: fplteam_1, gameweek: 34)
  end

  describe '.create_for_non_free_hitters' do
    it 'calls the create_for_non_free_hitters method with correct arguments' do
      expect(Penalty).to receive(:create_for_non_free_hitters).with(gameweek, illegal_players, last_weeks_free_hitters).and_call_original
      Penalty.create_for_non_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
    end

    it 'creates penalties for fplteams that did not free hit last week' do
      expect {
        Penalty.create_for_non_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
      }.to change(Penalty, :count).by(1)

      penalty = Penalty.last
      expect(penalty.fplteam).to eq(fplteam_2)
      expect(penalty.player).to eq(player_1)
    end
    it 'does not create penalties for fplteams that did free hit last week' do
      expect {
        Penalty.create_for_non_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
      }.to change(Penalty, :count).by(1)

      expect(Penalty.where(fplteam: fplteam_1, player: player_1)).not_to exist
    end
  end


  describe '.create_for_free_hitters' do
    it 'calls the create_for_free_hitters method with correct arguments' do
      expect(Penalty).to receive(:create_for_free_hitters).with(gameweek, illegal_players, last_weeks_free_hitters).and_call_original
      Penalty.create_for_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
    end

    it 'creates penalties for fplteams that did free hit last week' do
      expect {
        Penalty.create_for_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
      }.to change(Penalty, :count).by(1)

      penalty = Penalty.last
      expect(penalty.fplteam).to eq(fplteam_1)
      expect(penalty.player).to eq(player_2)
    end

    it 'does not create penalties for players that were only brought in on free hit last week' do
      expect {
        Penalty.create_for_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
      }.to change(Penalty, :count).by(1)

      expect(Penalty.where(fplteam: fplteam_1, player: player_1)).not_to exist
    end
  end

  describe '.create_for_previous_warnings' do
    it 'calls the create_for_previous_warnings method with correct arguments' do
      expect(Penalty).to receive(:create_for_previous_warnings).with(gameweek, last_weeks_free_hitters).and_call_original
      Penalty.create_for_previous_warnings(gameweek, last_weeks_free_hitters)
    end

    it 'creates penalties for free hit teams, unless one is already there from before' do
      expect {
        Penalty.create_for_previous_warnings(gameweek, last_weeks_free_hitters)
      }.to change(Penalty, :count).by(0)

      Penalty.create!(player: player_2, fplteam: fplteam_1, gameweek: 34, status: "pending")

      expect {
        Penalty.create_for_previous_warnings(gameweek, last_weeks_free_hitters)
      }.to change(Penalty, :count).by(1)

      penalty = Penalty.last
      expect(penalty.fplteam).to eq(fplteam_1)
      expect(penalty.player).to eq(player_2)
      expect(penalty.gameweek).to eq(35)
    end
  end

  describe '.create_or_update_penalty' do
    before do
      Sidekiq::Testing.fake!
    end

    after do
      Sidekiq::Testing.disable!
    end

    it 'calls the create_or_update_penalty method with correct arguments' do
      expect(Penalty).to receive(:create_or_update_penalty).with(Pick.first, gameweek, api_data).and_call_original
      Penalty.create_or_update_penalty(Pick.first, gameweek, api_data)
    end
    it 'creates penalties for illegal players not transferred out' do
      Penalty.create!(player: player_1, fplteam: fplteam_2, gameweek: 35, status: "pending")

      expect {
        Penalty.create_or_update_penalty(gw35_pick_2, gameweek, api_data)
      }.to change(Penalty, :count).by(0)

      penalty = Penalty.last
      expect(penalty.fplteam).to eq(fplteam_2)
      expect(penalty.player).to eq(player_1)
      expect(penalty.gameweek).to eq(35)
      expect(penalty.status).to eq("confirmed")
    end
    it 'creates a penalty for an illegal player transferred in' do
      allow(fplteam_1).to receive(:free_hit?).and_return(true)

      expect {
        Penalty.create_or_update_penalty(gw35_pick_1, gameweek, api_data)
      }.to change(Penalty, :count).by(1)

      penalty = Penalty.last
      expect(penalty.fplteam).to eq(fplteam_1)
      expect(penalty.player).to eq(player_3)
      expect(penalty.gameweek).to eq(35)
      expect(penalty.status).to eq("confirmed")
    end
    it 'does not create a penalty for a legal player transferred in' do
      expect {
        Penalty.create_or_update_penalty(gw35_pick_3, gameweek, api_data)
      }.to change(Penalty, :count).by(0)
    end
  end
end
