# Migration to create answers table and migrate existing boolean data
# This migration:
# 1. Creates the answers table with text field and survey_id foreign key
# 2. For each existing survey, creates "Yes" and "No" answer options
# 3. Migrates existing survey_response boolean answers to reference the appropriate answer
# 4. Removes the boolean answer column from survey_responses
class CreateAnswersAndMigrateSurveyResponses < ActiveRecord::Migration[7.1]
  def up
    # Step 1: Create answers table
    create_table :answers do |t|
      t.string :text, null: false
      t.references :survey, null: false, foreign_key: true, index: true

      t.timestamps
    end

    # Step 2: Add answer_id to survey_responses (temporarily nullable for migration)
    add_reference :survey_responses, :answer, foreign_key: true, index: true

    # Step 3: Data migration - create Yes/No answers for each survey and migrate responses
    if table_exists?(:surveys) && column_exists?(:survey_responses, :answer)
      # Use ActiveRecord for database-agnostic approach
      Survey.reset_column_information
      Answer.reset_column_information
      SurveyResponse.reset_column_information
      
      Survey.find_each do |survey|
        # Create Yes and No answers for this survey
        yes_answer = Answer.create!(text: 'Yes', survey: survey)
        no_answer = Answer.create!(text: 'No', survey: survey)
        
        # Update survey_responses: true -> Yes answer, false/nil -> No answer
        SurveyResponse.where(survey_id: survey.id, answer: true).update_all(answer_id: yes_answer.id)
        SurveyResponse.where(survey_id: survey.id, answer: [false, nil]).update_all(answer_id: no_answer.id)
      end
    end

    # Step 4: Remove the old boolean answer column
    remove_column :survey_responses, :answer if column_exists?(:survey_responses, :answer)

    # Step 5: Make answer_id non-nullable now that data is migrated
    change_column_null :survey_responses, :answer_id, false
  end

  def down
    # Add back the boolean answer column
    add_column :survey_responses, :answer, :boolean

    # Migrate data back: find answer text and set boolean accordingly
    if table_exists?(:survey_responses) && column_exists?(:survey_responses, :answer_id)
      SurveyResponse.reset_column_information
      Answer.reset_column_information
      
      SurveyResponse.includes(:answer).find_each do |sr|
        if sr.answer
          sr.update_column(:answer, sr.answer.text == 'Yes')
        end
      end
    end

    # Make answer column non-nullable
    change_column_null :survey_responses, :answer, false

    # Remove answer_id reference
    remove_reference :survey_responses, :answer, foreign_key: true, index: true

    # Drop answers table
    drop_table :answers
  end
end
