# frozen_string_literal: true

class PlayerComponent < ViewComponent::Base

  def initialize(player:, gameweek:)
    @player = player
    @gameweek = gameweek
    @shirt = shirt_image if @player.present?
  end

  def shirt_image
    if @player.element_type == 1
      Rails.logger.info(@player.web_name)
      "#{@player.shirt}_gk.png"
    else
      "#{@player.shirt}.png"
    end
  end
end
