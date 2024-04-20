require 'rails_helper'

RSpec.describe GetPendingPenaltiesJob, type: :job do
  let(:gameweek) { 34 }
  let(:illegal_players) { { Player.create(past_ownership_stats: {"34"=>16}) => 16 } }
  let(:last_weeks_free_hitters) { [Fplteam.create] }

  before do
    allow(Player).to receive(:illegal_players).and_return(illegal_players)
    allow(Fplteam).to receive(:last_weeks_free_hitters).and_return(last_weeks_free_hitters)
    allow(Penalty).to receive(:create_for_non_free_hitters)
    allow(Penalty).to receive(:create_for_free_hitters)
    allow(Penalty).to receive(:create_for_previous_warnings)
  end

  it 'calls the appropriate methods with the correct arguments' do
    GetPendingPenaltiesJob.perform_now

    expect(Player).to have_received(:illegal_players).with(gameweek)
    expect(Fplteam).to have_received(:last_weeks_free_hitters).with(gameweek)
    expect(Penalty).to have_received(:create_for_non_free_hitters).with(gameweek, illegal_players, last_weeks_free_hitters)
    expect(Penalty).to have_received(:create_for_free_hitters).with(gameweek, illegal_players, last_weeks_free_hitters)
    expect(Penalty).to have_received(:create_for_previous_warnings).with(gameweek, last_weeks_free_hitters)
  end
end
