class SurveyResponse < ApplicationRecord
  # Associations
  belongs_to :survey
  belongs_to :answer

  # Validations
  validates :answer_id, presence: true
end
