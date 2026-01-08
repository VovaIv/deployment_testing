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
end
