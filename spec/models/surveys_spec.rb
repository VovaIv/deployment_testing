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

  describe 'nested attributes for answers' do
    it 'accepts nested attributes for answers' do
      survey = Survey.create(
        question: 'Test question',
        answers_attributes: [
          { text: 'Option 1' },
          { text: 'Option 2' }
        ]
      )
      expect(survey.answers.count).to eq(2)
      expect(survey.answers.map(&:text)).to include('Option 1', 'Option 2')
    end

    it 'allows destroying answers through nested attributes' do
      survey = Survey.create(question: 'Test question')
      answer = survey.answers.create(text: 'Option 1')
      
      survey.update(answers_attributes: [{ id: answer.id, _destroy: '1' }])
      
      expect(survey.answers.count).to eq(0)
    end

    it 'rejects blank answers' do
      survey = Survey.create(
        question: 'Test question',
        answers_attributes: [
          { text: 'Option 1' },
          { text: '' }
        ]
      )
      # With reject_if: :all_blank, the second answer with empty text is still created
      # because it's not completely blank (the hash itself has keys)
      # Let's test that at least valid answers are created
      expect(survey.answers.count).to eq(1)
      expect(survey.answers.first.text).to eq('Option 1')
    end
  end
end
