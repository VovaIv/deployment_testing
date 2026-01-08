require 'rails_helper'

RSpec.describe SurveyResponse, type: :model do
  let!(:survey) { Survey.create(question: 'some question') }
  let!(:answer) { Answer.create(text: 'Yes', survey: survey) }

  it 'is valid if we have survey and answer' do
    survey_response = SurveyResponse.new(survey: survey, answer: answer)
    expect(survey_response).to be_valid
  end

  it 'is not valid without answer' do
    survey_response = SurveyResponse.new(survey: survey)
    expect(survey_response).not_to be_valid
  end
end
