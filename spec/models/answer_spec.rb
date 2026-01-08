require 'rails_helper'

RSpec.describe Answer, type: :model do
  let(:survey) { Survey.create(question: 'Test question') }

  it 'is valid with text and survey' do
    answer = Answer.new(text: 'Option 1', survey: survey)
    expect(answer).to be_valid
  end

  it 'is not valid without text' do
    answer = Answer.new(survey: survey)
    expect(answer).not_to be_valid
  end

  it 'belongs to a survey' do
    answer = Answer.create(text: 'Option 1', survey: survey)
    expect(answer.survey).to eq(survey)
  end
end
