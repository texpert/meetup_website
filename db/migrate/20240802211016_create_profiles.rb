class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_enum :profile_gender, %w[male female]

    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :full_name, null: false
      t.string :preferred_name
      t.string :nickname
      t.enum :gender, enum_type: :profile_gender
      t.date :birthday

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
