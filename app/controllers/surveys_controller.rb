class SurveysController < ApplicationController
  before_action :set_survey, only: [:edit, :update, :destroy]

  def index
    @surveys = Survey.all.paginate(page: params[:page], per_page: 5)
  end

  def new
    @survey = Survey.new
    # Pre-build one empty answer field for the form
    @survey.answers.build
  end
  
  def edit
    # Edit action for updating existing surveys with their answers
  end

  def create
    @survey = Survey.new(survey_params)
    if @survey.save
      redirect_to surveys_path, notice: 'Survey created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    if @survey.update(survey_params)
      redirect_to surveys_path, notice: 'Survey updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @survey.destroy
    redirect_to surveys_path, notice: 'Survey deleted successfully.'
  end

  private

  def set_survey
    @survey = Survey.find(params[:id])
  end

  # Strong parameters now include nested attributes for answers
  # This allows creating, updating, and deleting answers inline with the survey
  def survey_params
    params.require(:survey).permit(
      :question,
      # Nested attributes for answers
      # :id is needed for updating existing answers
      # :_destroy is needed for deleting answers (via Hotwire)
      answers_attributes: [:id, :text, :_destroy]
    )
  end
end
