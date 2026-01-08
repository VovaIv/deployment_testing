# Migration to update survey_responses to reference answers instead of boolean values
# Converts from boolean answer field to answer_id foreign key
class UpdateSurveyResponsesForAnswers < ActiveRecord::Migration[7.1]
  def up
    # Add answer_id column to reference the Answer model
    # This allows survey responses to reference specific answer options
    add_reference :survey_responses, :answer, foreign_key: true, index: true
    
    # Remove the old boolean answer field if it exists
    # The old field only supported true/false, new structure supports multiple text answers
    remove_column :survey_responses, :answer if column_exists?(:survey_responses, :answer)
  end

  def down
    # Rollback: restore the boolean answer field (nullable for safety)
    add_column :survey_responses, :answer, :boolean, null: true
    
    # Remove the answer_id reference
    remove_reference :survey_responses, :answer, foreign_key: true, index: true
  end
end
