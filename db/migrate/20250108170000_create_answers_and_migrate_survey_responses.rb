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
    # We need to use execute or ActiveRecord if available
    if table_exists?(:surveys)
      # Get all surveys
      surveys = execute("SELECT id FROM surveys").to_a
      
      surveys.each do |survey_row|
        survey_id = survey_row['id']
        
        # Create Yes and No answers for this survey
        execute("INSERT INTO answers (text, survey_id, created_at, updated_at) VALUES ('Yes', #{survey_id}, NOW(), NOW())")
        yes_answer_id = execute("SELECT LAST_INSERT_ID() as id").first['id']
        
        execute("INSERT INTO answers (text, survey_id, created_at, updated_at) VALUES ('No', #{survey_id}, NOW(), NOW())")
        no_answer_id = execute("SELECT LAST_INSERT_ID() as id").first['id']
        
        # Update survey_responses: true -> Yes answer, false -> No answer
        execute("UPDATE survey_responses SET answer_id = #{yes_answer_id} WHERE survey_id = #{survey_id} AND answer = TRUE")
        execute("UPDATE survey_responses SET answer_id = #{no_answer_id} WHERE survey_id = #{survey_id} AND answer = FALSE")
      end
    end

    # Step 4: Remove the old boolean answer column
    remove_column :survey_responses, :answer

    # Step 5: Make answer_id non-nullable now that data is migrated
    change_column_null :survey_responses, :answer_id, false
  end

  def down
    # Add back the boolean answer column
    add_column :survey_responses, :answer, :boolean

    # Migrate data back: find answer text and set boolean accordingly
    if table_exists?(:survey_responses) && column_exists?(:survey_responses, :answer_id)
      execute(<<-SQL)
        UPDATE survey_responses sr
        JOIN answers a ON sr.answer_id = a.id
        SET sr.answer = CASE
          WHEN a.text = 'Yes' THEN TRUE
          WHEN a.text = 'No' THEN FALSE
          ELSE FALSE
        END
      SQL
    end

    # Make answer column non-nullable
    change_column_null :survey_responses, :answer, false

    # Remove answer_id reference
    remove_reference :survey_responses, :answer, foreign_key: true, index: true

    # Drop answers table
    drop_table :answers
  end
end
