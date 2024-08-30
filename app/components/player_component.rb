# frozen_string_literal: true

class PlayerComponent < ViewComponent::Base

  def initialize(player:, gameweek:)
    @player = player
    @gameweek = gameweek
    @shirt = shirt_image
  end

  def shirt_image
    if @player.element_type == 1
      "#{@player.shirt}_gk.png"
    else
      "#{@player.shirt}.png"
    end
  end
end
