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

  it 'can have answers' do
    survey = Survey.create(question: 'some question')
    answer1 = Answer.create(text: 'Yes', survey: survey)
    answer2 = Answer.create(text: 'No', survey: survey)
    
    expect(survey.answers).to include(answer1, answer2)
  end

  it 'destroys answers when deleted' do
    survey = Survey.create(question: 'some question')
    Answer.create(text: 'Yes', survey: survey)
    Answer.create(text: 'No', survey: survey)
    
    expect { survey.destroy }.to change { Answer.count }.by(-2)
  end

  it 'accepts nested attributes for answers' do
    survey = Survey.new(question: 'some question', answers_attributes: [
      { text: 'Yes' },
      { text: 'No' }
    ])
    
    survey.save
    expect(survey.answers.count).to eq 2
    expect(survey.answers.map(&:text)).to contain_exactly('Yes', 'No')
  end

  it 'calculates answer counts and percentages' do
    survey = Survey.create(question: 'some question')
    yes_answer = Answer.create(text: 'Yes', survey: survey)
    no_answer = Answer.create(text: 'No', survey: survey)
    
    # Create 3 'Yes' responses and 1 'No' response
    3.times { SurveyResponse.create(survey: survey, answer: yes_answer) }
    1.times { SurveyResponse.create(survey: survey, answer: no_answer) }
    
    expect(survey.total_responses_count).to eq 4
    expect(survey.answer_count(yes_answer.id)).to eq 3
    expect(survey.answer_count(no_answer.id)).to eq 1
    expect(survey.answer_percentage(yes_answer.id)).to eq 75.00
    expect(survey.answer_percentage(no_answer.id)).to eq 25.00
  end
end
