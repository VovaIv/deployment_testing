class Survey < ApplicationRecord
  has_many :survey_responses, dependent: :destroy
  has_many :answers, dependent: :destroy

  validates :question, presence: true

  def percentage_yes
    return 0 if total_responses_count.zero?

    (answers_yes_count.to_f / total_responses_count * 100).round(2)
  end

  def percentage_no
    return 0 if total_responses_count.zero?

    (answers_no_count.to_f / total_responses_count * 100).round(2)
  end

  def answers_yes_count
    total_responses[true].to_i
  end

  def answers_no_count
    total_responses[false].to_i
  end

  def total_responses_count
    @total_responses_count ||= total_responses.values.sum
  end

  def total_responses
    @total_responses ||= survey_responses.group(:answer).count
  end
end
