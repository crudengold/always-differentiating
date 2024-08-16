# frozen_string_literal: true

class PlayerComponent < ViewComponent::Base
  def initialize(player:, position:)
    @player = player
    @position = position
  end
end
