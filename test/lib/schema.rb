ActiveRecord::Schema.define do
  create_table :users, :force => true do |t|
    t.string   :username
    t.string   :password
    t.timestamps
  end

  add_index :users, :username, :unique => true
end