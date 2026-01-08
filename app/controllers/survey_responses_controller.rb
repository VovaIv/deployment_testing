class SurveyResponsesController < ApplicationController
  helper_method :survey

  def new
    @survey_response = survey.survey_responses.new

    respond_to(&:turbo_stream)
  end

  def create
    @survey_response = SurveyResponse.new(survey_response_params)
    respond_to do |format|
      if @survey_response.save
        format.turbo_stream { render 'update', locals: { survey: survey } }
      else
        format.turbo_stream { render 'new', status: :unprocessable_entity }
      end
    end
  end

  private

  def survey
    @survey ||= Survey.find(params[:survey_id]) || survey_response_params[:survey_id]
  end

  # Updated to use answer_id instead of boolean answer field
  def survey_response_params
    params.require(:survey_response).permit(:answer_id, :survey_id)
  end
end
