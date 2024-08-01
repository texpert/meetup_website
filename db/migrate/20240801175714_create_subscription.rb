class CreateSubscription < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.bigint "owner_id", null: false
      t.text "owner_type", null: false
      t.bigint "plan_id", null: false
      t.integer "status", null: false
      t.datetime "canceled_at", precision: nil
      t.datetime "terminated_at", precision: nil
      t.datetime "started_at", precision: nil
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "previous_subscription_id"
      t.string "name"
      t.integer "billing_time", default: 0, null: false
      t.datetime "subscription_at"
      t.datetime "ending_at"
      t.datetime "trial_ended_at"
      t.datetime "deleted_at"
      t.index ["owner_id", "owner_type"], name: "index_subscriptions_on_owner_id_and_owner_type"
      t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
      t.index ["previous_subscription_id", "status"], name: "index_subscriptions_on_previous_subscription_id_and_status"
      t.index ["started_at", "ending_at"], name: "index_subscriptions_on_started_at_and_ending_at"
      t.index ["started_at"], name: "index_subscriptions_on_started_at"
      t.index ["status"], name: "index_subscriptions_on_status"
      t.index ["deleted_at"], name: "index_subsriptions_on_deleted_at"
    end
  end
end
