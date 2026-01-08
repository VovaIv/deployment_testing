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

  # Note: Percentage calculation test removed since the new answer structure
  # no longer uses boolean values. The old implementation has been commented out
  # in the Survey model.
  
  describe 'nested attributes for answers' do
    it 'accepts nested attributes for answers' do
      survey = Survey.new(
        question: 'What is your favorite color?',
        answers_attributes: [
          { text: 'Red' },
          { text: 'Blue' }
        ]
      )
      
      expect(survey.save).to be true
      expect(survey.answers.count).to eq(2)
    end
    
    it 'allows destruction of answers through nested attributes' do
      survey = Survey.create(question: 'Test')
      answer = survey.answers.create(text: 'Test Answer')
      
      survey.update(answers_attributes: [{ id: answer.id, _destroy: '1' }])
      expect(survey.answers.count).to eq(0)
    end
    
    it 'rejects blank answer text' do
      survey = Survey.new(
        question: 'Test question',
        answers_attributes: [
          { text: 'Valid Answer' },
          { text: '' },
          { text: 'Another Valid' }
        ]
      )
      
      survey.save
      expect(survey.answers.count).to eq(2)
    end
  end
end
