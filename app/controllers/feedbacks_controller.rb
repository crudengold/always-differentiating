class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      redirect_to root_path, notice: 'Feedback was successfully created.'
    else
      render :new
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:name, :feedback)
  end
end
