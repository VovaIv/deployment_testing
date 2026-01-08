class SurveyResponse < ApplicationRecord
  belongs_to :survey
  belongs_to :answer

  validates :answer_id, presence: true
end
