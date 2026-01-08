# Answer model - represents a possible answer option for a survey
# Each survey can have multiple answer options (e.g., "Yes", "No", "Maybe", etc.)
class Answer < ApplicationRecord
  belongs_to :survey
  has_many :survey_responses, dependent: :destroy

  validates :text, presence: true
end
