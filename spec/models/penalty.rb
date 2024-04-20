# spec/models/penalty_spec.rb
require 'rails_helper'

RSpec.describe Penalty, type: :model do
  describe '.create_for_non_free_hitters' do
    let(:gameweek) { 34 }
    let(:player) { Player.create }
    let(:illegal_players) { { player => 16 } }
    let(:fplteam) { Fplteam.create }
    let(:last_weeks_free_hitters) { fplteam }

    before do
      allow(Penalty).to receive(:create_for_non_free_hitters)
      illegal_players.each_key do |player|
        Pick.create(player: player, fplteam: fplteam, gameweek: gameweek)
      end
    end

    it 'calls the create_for_non_free_hitters method with correct arguments' do
      Penalty.create_for_non_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
      expect(Penalty).to have_received(:create_for_non_free_hitters).with(gameweek, illegal_players, last_weeks_free_hitters)
    end

    it 'creates penalties for non-free hitters' do
      expect {
        Penalty.create_for_non_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
      }.to change(Penalty, :count).by(1)
    end
  end
end
