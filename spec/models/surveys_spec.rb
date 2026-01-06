require 'rails_helper'

RSpec.describe Survey, type: :model do
  it 'is valid if we have question' do
    survey = Survey.new(question: 'some question')
    expect(survey).to be_valid
  end

  it 'is not valid without a question' do
    survey = Survey.new

    expect(survey).not_to be_valid
  end

  it 'calculate percentage of responses' do
    survey = Survey.new(question: 'some question')
    [true, true, true, false].each do |answer|
      SurveyResponse.create(survey: survey, answer: answer)
    end
    expect(survey.percentage_yes).to eq 75.00
    expect(survey.percentage_no).to eq 25.00
  end
end
