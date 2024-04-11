class UpdatePenaltyPointsJob < ApplicationJob
  queue_as :default

  def perform(penalty)
    # Do something later
    penalty.update_deducted_points
  end
end
