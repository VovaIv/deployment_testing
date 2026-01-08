require 'rails_helper'

RSpec.describe Answer, type: :model do
  let!(:survey) { Survey.create(question: 'some question') }

  it 'is valid with text and survey' do
    answer = Answer.new(text: 'Yes', survey: survey)
    expect(answer).to be_valid
  end

  it 'is not valid without text' do
    answer = Answer.new(survey: survey)
    expect(answer).not_to be_valid
  end

  it 'is not valid without survey' do
    answer = Answer.new(text: 'Yes')
    expect(answer).not_to be_valid
  end

  it 'can have survey responses' do
    answer = Answer.create(text: 'Yes', survey: survey)
    survey_response = SurveyResponse.create(survey: survey, answer: answer)
    
    expect(answer.survey_responses).to include(survey_response)
  end

  it 'destroys associated survey responses when deleted' do
    answer = Answer.create(text: 'Yes', survey: survey)
    survey_response = SurveyResponse.create(survey: survey, answer: answer)
    
    expect { answer.destroy }.to change { SurveyResponse.count }.by(-1)
  end
end
