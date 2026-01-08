class SurveysController < ApplicationController
  before_action :set_survey, only: [:edit, :update, :destroy]

  def index
    @surveys = Survey.all.paginate(page: params[:page], per_page: 5)
  end

  def new
    @survey = Survey.new
    # Build initial answer fields for the form
    2.times { @survey.answers.build }
  end

  def create
    @survey = Survey.new(survey_params)
    if @survey.save
      redirect_to surveys_path, notice: 'Survey created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Build additional empty answer fields if needed
    @survey.answers.build if @survey.answers.empty?
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

  def survey_params
    params.require(:survey).permit(
      :question,
      answers_attributes: [:id, :text, :_destroy]
    )
  end
end
