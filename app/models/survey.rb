class Survey < ApplicationRecord
  # Associations
  has_many :survey_responses, dependent: :destroy
  has_many :answers, dependent: :destroy
  
  # Nested attributes support for inline answer management in forms
  accepts_nested_attributes_for :answers, 
    allow_destroy: true,
    reject_if: proc { |attrs| attrs['text'].blank? }

  # Validations
  validates :question, presence: true

  # Statistics methods - now work with Answer model instead of boolean
  def total_responses_count
    survey_responses.count
  end

  # Get count of responses per answer
  # Returns a hash like: { Answer(id: 1, text: "Yes") => 5, Answer(id: 2, text: "No") => 3 }
  # Uses eager loading to avoid N+1 queries
  def answer_counts
    @answer_counts ||= begin
      # Load survey_responses with answers in a single query
      counts_by_id = survey_responses.group(:answer_id).count
      
      # Map answer IDs to answer objects (answers are already loaded for this survey)
      answer_ids_to_answers = answers.index_by(&:id)
      
      # Transform keys from IDs to Answer objects
      counts_by_id.transform_keys { |answer_id| answer_ids_to_answers[answer_id] }.compact
    end
  end

  # Get count for a specific answer by id
  def answer_count(answer_id)
    survey_responses.where(answer_id: answer_id).count
  end

  # Get percentage for a specific answer
  def answer_percentage(answer_id)
    return 0 if total_responses_count.zero?
    (answer_count(answer_id).to_f / total_responses_count * 100).round(2)
  end
end
