class AnswersController < ApplicationController
  def new
    @answer = Answer.new
    @surveys = Survey.all
  end

  def create
    @answer = Answer.new(answer_params)
    
    if @answer.save
      redirect_to root_path, notice: 'Answer created successfully.'
    else
      @surveys = Survey.all
      render :new, status: :unprocessable_entity
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:text, :survey_id)
  end
end
