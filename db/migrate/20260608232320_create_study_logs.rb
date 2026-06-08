class CreateStudyLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :study_logs do |t|
      t.integer :studied_minutes
      t.date :logged_on
      t.text :memo
      t.references :certification, null: false, foreign_key: true

      t.timestamps
    end
  end
end
