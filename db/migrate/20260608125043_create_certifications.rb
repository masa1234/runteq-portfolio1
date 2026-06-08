class CreateCertifications < ActiveRecord::Migration[7.1]
  def change
    create_table :certifications do |t|
      t.string :name, null: false
      t.date :exam_date, null: false
      t.integer :target_minutes, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
