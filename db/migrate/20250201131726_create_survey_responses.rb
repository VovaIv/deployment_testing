class CreateSurveyResponses < ActiveRecord::Migration[7.1]
  def change
    create_table :survey_responses do |t|
      t.references :survey, null: false, foreign_key: true
      t.boolean :answer, null: false

      t.timestamps
    end
  end
end
