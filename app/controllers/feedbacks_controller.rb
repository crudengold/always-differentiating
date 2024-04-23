class FeedbacksController < ApplicationController
  def create
    Rails.logger.debug params.inspect
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      redirect_to root_path, notice: 'Feedback was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy
    redirect_to admin_path, notice: 'Feedback was deleted.'
  end

  private

  def feedback_params
    params.require(:feedback).permit(:name, :feedback)
  end
end
