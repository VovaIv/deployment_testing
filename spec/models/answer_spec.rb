require 'rails_helper'

RSpec.describe Answer, type: :model do
  let!(:survey) { Survey.create(question: 'What is your favorite color?') }

  it 'is valid with valid attributes' do
    answer = Answer.new(text: 'Blue', survey: survey)
    expect(answer).to be_valid
  end

  it 'is not valid without text' do
    answer = Answer.new(survey: survey)
    expect(answer).not_to be_valid
  end

  it 'is not valid without a survey' do
    answer = Answer.new(text: 'Blue')
    expect(answer).not_to be_valid
  end

  it 'belongs to a survey' do
    answer = Answer.new(text: 'Blue', survey: survey)
    answer.save
    expect(answer.survey).to eq(survey)
  end

  it 'has many survey_responses' do
    answer = Answer.create(text: 'Blue', survey: survey)
    expect(answer).to respond_to(:survey_responses)
  end

  it 'destroys associated survey_responses when destroyed' do
    answer = Answer.create(text: 'Blue', survey: survey)
    survey_response = SurveyResponse.create(survey: survey, answer: answer)
    
    expect { answer.destroy }.to change { SurveyResponse.count }.by(-1)
  end
end
