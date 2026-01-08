# Answer model represents a predefined answer option for a survey
# Examples: "Yes", "No", "Maybe", "Strongly Agree", etc.
#
# Associations:
#   - belongs_to :survey - Each answer is associated with one survey
#   - has_many :survey_responses - Tracks how many times this answer was selected
class Answer < ApplicationRecord
  # Each answer belongs to a specific survey
  belongs_to :survey
  
  # Many survey responses can select this answer
  # When an answer is destroyed, cascade delete the responses
  has_many :survey_responses, dependent: :destroy

  # Validations
  validates :text, presence: true
end
