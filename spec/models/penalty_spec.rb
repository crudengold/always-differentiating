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
      illegal_players.each_key do |player|
        Pick.create(player: player, fplteam: fplteam, gameweek: gameweek)
      end
    end

    it 'calls the create_for_non_free_hitters method with correct arguments' do
      expect(Penalty).to receive(:create_for_non_free_hitters).with(gameweek, illegal_players, last_weeks_free_hitters).and_call_original
      Penalty.create_for_non_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
    end

    it 'creates penalties for fplteams that did not free hit last week' do
      gameweek = 30
      player = create(:player)
      illegal_players = {player => 16}
      last_weeks_free_hitters = []
      fplteam = create(:fplteam)

      Pick.create!(player: player, fplteam: fplteam, gameweek: gameweek - 1)

      expect {
        Penalty.create_for_non_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
      }.to change(Penalty, :count).by(1)

      last_weeks_free_hitters = [fplteam]

      expect {
        Penalty.create_for_non_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
      }.to change(Penalty, :count).by(0)
    end
  end


  describe '.create_for_free_hitters' do
    let(:gameweek) { 34 }
    let(:player) { Player.create }
    let(:illegal_players) { { player => 16 } }
    let(:fplteam) { Fplteam.create }
    let(:last_weeks_free_hitters) { fplteam }

    before do
      illegal_players.each_key do |player|
        Pick.create(player: player, fplteam: fplteam, gameweek: gameweek)
      end
    end

    it 'calls the create_for_free_hitters method with correct arguments' do
      expect(Penalty).to receive(:create_for_free_hitters).with(gameweek, illegal_players, last_weeks_free_hitters).and_call_original
      Penalty.create_for_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
    end
    it 'creates penalties for last weeks free hitters, checking their teams two weeks ago' do
      gameweek = 30
      player = create(:player)
      illegal_players = {player => 16}
      fplteam = create(:fplteam)
      last_weeks_free_hitters = [fplteam]

      Pick.create!(player: player, fplteam: fplteam, gameweek: gameweek - 2)

      expect {
        Penalty.create_for_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
      }.to change(Penalty, :count).by(1)

      last_weeks_free_hitters = []

      expect {
        Penalty.create_for_free_hitters(gameweek, illegal_players, last_weeks_free_hitters)
      }.to change(Penalty, :count).by(0)
    end
  end

  describe '.create_for_previous_warnings' do
    let(:gameweek) { 34 }
    let(:player) { Player.create }
    let(:illegal_players) { { player => 16 } }
    let(:fplteam) { Fplteam.create }
    let(:last_weeks_free_hitters) { [ fplteam ] }

    before do
      illegal_players.each_key do |player|
        Pick.create(player: player, fplteam: fplteam, gameweek: gameweek)
      end
    end

    it 'calls the create_for_previous_warnings method with correct arguments' do
      expect(Penalty).to receive(:create_for_previous_warnings).with(gameweek, last_weeks_free_hitters).and_call_original
      Penalty.create_for_previous_warnings(gameweek, last_weeks_free_hitters)
    end

    it 'creates penalties for free hit teams, unless one is already there from before' do
      gameweek = 30
      player = create(:player)
      illegal_players = {player => 16}
      fplteam = create(:fplteam)
      last_weeks_free_hitters = [fplteam]

      Pick.create!(player: player, fplteam: fplteam, gameweek: gameweek - 2)

      expect {
        Penalty.create_for_previous_warnings(gameweek, last_weeks_free_hitters)
      }.to change(Penalty, :count).by(0)

      Penalty.create!(player: player, fplteam: fplteam, gameweek: gameweek - 1)

      expect {
        Penalty.create_for_previous_warnings(gameweek, last_weeks_free_hitters)
      }.to change(Penalty, :count).by(1)

      last_weeks_free_hitters = []

      expect {
        Penalty.create_for_previous_warnings(gameweek, last_weeks_free_hitters)
      }.to change(Penalty, :count).by(0)
    end
  end
end
