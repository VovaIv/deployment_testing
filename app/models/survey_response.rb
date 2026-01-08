# SurveyResponse model represents a user's response to a survey
#
# Associations:
#   - belongs_to :survey - The survey being responded to
#   - belongs_to :answer - The specific answer option selected by the user
#
# Note: This model was refactored from storing boolean answers (true/false)
# to referencing Answer entities, allowing for multiple text-based answer options
class SurveyResponse < ApplicationRecord
  belongs_to :survey
  # Each response selects one of the predefined answers for the survey
  belongs_to :answer

  # Validate that an answer is selected
  validates :answer_id, presence: true
end
