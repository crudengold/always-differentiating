require 'rails_helper'

RSpec.describe UpdatePenaltiesJob, type: :job do
  let(:gameweek) { 35 }
  let(:fplteam) { create(:fplteam) }
  let(:player_2) { create(:over_15_player) }
  let(:player_3) { create(:over_10_player) }
  let(:player_4) { create(:under_10_player) }

  before do
    allow(Gameweek).to receive(:new).with("current").and_return(double(gw_num: gameweek))
  end

  context "when the team has used a free hit" do
    before do
      allow(URI).to receive(:open).and_return(double(read: '{"free_hit": true}'))
      allow(fplteam).to receive(:free_hit?).with(gameweek).and_return(true)
    end

    it "does not process the team's picks" do
      expect(fplteam).not_to receive(:picks)
      described_class.perform_now
    end
  end

  context "when the team has not used a free hit" do
    before do
      allow(URI).to receive(:open).and_return(double(read: '{"free_hit": false}'))
      allow(fplteam).to receive(:free_hit?).with(gameweek).and_return(false)
      allow(fplteam).to receive(:picks).and_return({ gameweek.to_s => [player_2.fpl_id, player_3.fpl_id, player_4.fpl_id] })
    end

    context "when the player has an ownership percentage over 15%" do
      before do
        allow(Player).to receive(:find_by).with(fpl_id: player_2.fpl_id).and_return(player_2)
        allow(player_2).to receive(:over_15_percent).with(gameweek).and_return(true)
      end

      it "creates or updates a penalty for the players" do
        expect(Penalty).to receive(:create_or_update_penalty).with(player_2, gameweek, fplteam)
        described_class.perform_now
      end
    end

    context "when the player has an ownership percentage between 10% and 15% and is a new pick" do
      before do
        allow(Player).to receive(:find_by).with(fpl_id: player_3.fpl_id).and_return(player_3)
        allow(player_3).to receive(:over_15_percent).with(gameweek).and_return(false)
        allow(player_3).to receive(:ten_to_fifteen_percent).with(gameweek).and_return(true)
        allow(player_3).to receive(:is_new_pick).with(fplteam, gameweek).and_return(true)
      end

      it "creates or updates a penalty for the player" do
        expect(Penalty).to receive(:create_or_update_penalty).with(player_3, gameweek, fplteam)
        described_class.perform_now
      end
    end

    context "when the player does not meet any penalty criteria" do
      before do
        allow(Player).to receive(:find_by).with(fpl_id: player_4.fpl_id).and_return(player_4)
        allow(player_4).to receive(:over_15_percent).with(gameweek).and_return(false)
        allow(player_4).to receive(:ten_to_fifteen_percent).with(gameweek).and_return(false)
      end

      it "does not create or update a penalty for the player" do
        expect(Penalty).not_to receive(:create_or_update_penalty).with(player_4, gameweek, fplteam)
        described_class.perform_now
      end
    end
  end
end
