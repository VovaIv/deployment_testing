class CreateAnswers < ActiveRecord::Migration[7.1]
  def change
    create_table :answers do |t|
      t.text :text
      t.references :survey, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
