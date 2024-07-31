class CreatePlan < ActiveRecord::Migration[7.1]
  def change
    create_table :plans do |t|
      t.bigint "organization_id"
      t.string "name", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "code", null: false
      t.integer "interval", null: false
      t.string "description"
      t.bigint "amount_cents", null: false
      t.string "amount_currency", null: false
      t.float "trial_period"
      t.boolean "pay_in_advance", default: true, null: false
      t.boolean "bill_charges_monthly"
      t.bigint "parent_id"
      t.datetime "deleted_at"
      t.boolean "pending_deletion", default: false, null: false
      t.string "invoice_display_name"
      t.index ["created_at"], name: "index_plans_on_created_at"
      t.index ["deleted_at"], name: "index_plans_on_deleted_at"
      t.index ["code"], name: "index_plans_on_code", unique: true, where: "((deleted_at IS NULL) AND (parent_id IS NULL))"
      t.index ["organization_id"], name: "index_plans_on_organization_id"
      t.index ["parent_id"], name: "index_plans_on_parent_id"
    end
  end
end
