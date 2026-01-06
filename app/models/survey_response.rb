class SurveyResponse < ApplicationRecord
  belongs_to :survey

  validates :answer, inclusion: { in: [true, false] }
end
