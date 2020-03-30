class SmsRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :sms_requests do |t|
      t.string :phone, null: false, default: ""
      t.string :dui, null: false, default: ""
      t.integer :status, default: 0
      t.integer :priority, default: 0
      t.integer :attempts, default: 0
      t.text :last_error, default: 0
      t.datetime :locked_at

      t.timestamps
    end

  end
end
