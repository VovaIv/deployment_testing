# Migration to create the answers table
# Answers store predefined answer options for surveys
# Each answer belongs to a survey and can have many survey_responses
class CreateAnswers < ActiveRecord::Migration[7.1]
  def change
    create_table :answers do |t|
      # The answer text that users will see and select
      t.text :text, null: false
      
      # Foreign key to associate answer with a survey
      # Each survey can have multiple answers (e.g., "Yes", "No", "Maybe")
      t.references :survey, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
