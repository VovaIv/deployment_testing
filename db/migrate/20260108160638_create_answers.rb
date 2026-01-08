class CreateAnswers < ActiveRecord::Migration[7.1]
  def change
    create_table :answers do |t|
      t.references :survey, null: false, foreign_key: true
      t.string :text

      t.timestamps
    end
  end
end
