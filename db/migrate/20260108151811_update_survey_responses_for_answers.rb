class UpdateSurveyResponsesForAnswers < ActiveRecord::Migration[7.1]
  def up
    # Add answer_id column first
    add_reference :survey_responses, :answer, foreign_key: true, index: true
    
    # Remove the boolean answer field
    remove_column :survey_responses, :answer if column_exists?(:survey_responses, :answer)
  end

  def down
    # Add back the answer boolean field
    add_column :survey_responses, :answer, :boolean, null: false, default: false
    
    # Remove answer_id
    remove_reference :survey_responses, :answer, foreign_key: true, index: true
  end
end
