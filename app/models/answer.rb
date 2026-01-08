class Answer < ApplicationRecord
  belongs_to :survey
  has_many :survey_responses, dependent: :destroy

  validates :text, presence: true
  validates :survey_id, presence: true
end
