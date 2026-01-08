# Survey model represents a survey question with multiple answer options
#
# Associations:
#   - has_many :survey_responses - Tracks all responses to this survey
#   - has_many :answers - The predefined answer options for this survey
#
# Nested Attributes:
#   - Accepts nested attributes for answers, allowing them to be created/updated/deleted
#     inline with the survey form using Hotwire
class Survey < ApplicationRecord
  has_many :survey_responses, dependent: :destroy
  # Each survey can have multiple predefined answers (e.g., "Yes", "No", "Maybe")
  has_many :answers, dependent: :destroy
  
  # Enable nested attributes for answers
  # This allows creating, updating, and deleting answers inline within the survey form
  # allow_destroy: true enables deletion of answers via _destroy flag
  # reject_if: proc ensures empty answer fields are not saved
  accepts_nested_attributes_for :answers, 
                                allow_destroy: true, 
                                reject_if: proc { |attributes| attributes['text'].blank? }

  validates :question, presence: true

  # Note: The following methods were designed for boolean answers
  # They are commented out since the new structure uses Answer entities with text values
  # Future implementation could calculate statistics per answer option
  # 
  # def percentage_yes
  #   return 0 if total_responses_count.zero?
  #
  #   (answers_yes_count.to_f / total_responses_count * 100).round(2)
  # end
  #
  # def percentage_no
  #   return 0 if total_responses_count.zero?
  #
  #   (answers_no_count.to_f / total_responses_count * 100).round(2)
  # end
  #
  # def answers_yes_count
  #   total_responses[true].to_i
  # end
  #
  # def answers_no_count
  #   total_responses[false].to_i
  # end
  #
  # def total_responses_count
  #   @total_responses_count ||= total_responses.values.sum
  # end
  #
  # def total_responses
  #   @total_responses ||= survey_responses.group(:answer).count
  # end
end
